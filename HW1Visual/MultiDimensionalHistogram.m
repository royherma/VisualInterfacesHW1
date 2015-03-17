//
//  MultiDimensionalHistogram.m
//  HW1Visual
//
//  Created by Roy Hermann on 3/11/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//
#define NUMBER_OF_BINS 8
#import "MultiDimensionalHistogram.h"

@interface MultiDimensionalHistogram ()

@property int maxHits;

@end


@implementation MultiDimensionalHistogram



-(id)initProperties{

    if(self=[super init]){
    //each green bin will have a full red and blue histogram
        _greenHistograms = [NSMutableArray new];
        _greenBinValues = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil];
        _numberOfBlackPixels = 0;
        
        //create red/blue histogram (4x4)
        _redAndBlueHistograms = [[NSMutableArray alloc] initWithCapacity: 8];
        
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        [_redAndBlueHistograms insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil] atIndex:0];
        
        for(int i=0;i<NUMBER_OF_BINS;i++){
            [_greenHistograms addObject:_redAndBlueHistograms];
        }
        
        //these will hold key/value as imageID/hits
        _mostSimilarHistograms = [[NSMutableArray alloc]initWithCapacity:3];
        _mostDifferentHistograms = [[NSMutableArray alloc]initWithCapacity:3];
        _comparedHistograms = [NSMutableDictionary new]; //array of dictionaries
        _maxHits = 64;
        _totalNumberOfPixels = 0;
        return self;
    }
    return nil;
    
}
-(void)addRed:(float)red green:(float)green blue:(float)blue{
    //first increment the green bin value
    NSNumber *greenBinValue = _greenBinValues[[self indexFromValue:green]];
    greenBinValue = [NSNumber numberWithInt:[greenBinValue intValue]+1];
    _greenBinValues[[self indexFromValue:green]] = greenBinValue;
    
    //now get indexes of red and blue
    int redIndx = [self indexFromValue:red];
    int blueIndex = [self indexFromValue:blue];
    
    //get relevant red/blue histogram
    NSMutableArray *redBlueHisto = _greenHistograms[[self indexFromValue:green]];
    //inrement that bins value
    NSNumber *redBlueValue = redBlueHisto[redIndx][blueIndex];
    redBlueValue = [NSNumber numberWithInt:[redBlueValue intValue]+1];
    redBlueHisto[redIndx][blueIndex] = redBlueValue;
    _totalNumberOfPixels++;
    _totalNumberOfPixels++;
    
     
}
-(int)indexFromValue:(float)value{
    int v = (int)value;
    int segment = 255/NUMBER_OF_BINS;
    for(int i=0;i<NUMBER_OF_BINS;i++){
        if(v < segment * i)
            return i;
    }
    return 0;
    
}
#pragma mark - Comparison

-(NSDictionary*)compareWithHistogram:(MultiDimensionalHistogram*)b{
    //if they are the same, dont compare
    if (self.imageIndex == b.imageIndex) return nil;
    
    int totalPixelsA = _totalNumberOfPixels;
    int totalPixelsB = b.totalNumberOfPixels;
    
    double difference = 0.0;
    
    //L1 difference calcuation
    for(int i=0;i<self.greenBinValues.count;i++){
        double normalizedGreenBinA = [self.greenBinValues[i] doubleValue] / totalPixelsA;
        double normalizedGreenBinB = [b.greenBinValues[i]doubleValue] / totalPixelsB;
        double calc = normalizedGreenBinA - normalizedGreenBinB;
        if(calc < 0) {
            calc = calc * -1;
        }
        difference += calc;
    }
    for(int i=0;i<self.redAndBlueHistograms.count;i++){
        for(int j=0;j<[self.redAndBlueHistograms[0]count];j++){
            double normalizedRedBlueBinA = [self.redAndBlueHistograms[i][j] doubleValue] / totalPixelsA;
            double normalizedRedBlueBinB = [b.redAndBlueHistograms[i][j] doubleValue] / totalPixelsB;
            double calc = normalizedRedBlueBinA - normalizedRedBlueBinB;
            if(calc < 0) {
                calc = calc * -1;
            }
            difference += calc;
        }
    }
    
    difference = difference/2; //divide by number of camparitors

    double similarity = 1 - difference;
    [_comparedHistograms setObject:[NSNumber numberWithDouble:similarity] forKey:[NSString stringWithFormat:@"%i",b.imageIndex]];
    
    return _comparedHistograms;
}
-(NSMutableArray*)getThreeLowest{
    NSMutableArray *temp = _comparedHistograms;
    
    for(int i =0;i<3;i++){
        NSDictionary* minDic = temp[0];
        for(int j=0;j<temp.count;j++){
            NSDictionary *newDic = temp[j];
            if(newDic.allValues[0] < minDic.allValues[0])
                minDic = newDic;
        }
        [temp removeObject:minDic];
        [_mostDifferentHistograms addObject:minDic];
    }
    
    NSArray *sortedArray;
    sortedArray = [_mostDifferentHistograms sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *first, NSDictionary *second) {
        // Calculate distances for each dictionary from the device
        // ...
        return ([first.allValues[0] doubleValue]-[second.allValues[0]doubleValue]);
    }];
    _mostDifferentHistograms = [NSMutableArray arrayWithArray:sortedArray];
    return _mostDifferentHistograms;
}
-(NSArray*)sortArrayDescending{

    NSArray *myArray;
    
    myArray = [_comparedHistograms keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 doubleValue] < [obj2 doubleValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 doubleValue] > [obj2 doubleValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    return myArray;
}
@end

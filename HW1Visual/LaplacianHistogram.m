//
//  LaplacianHistogram.m
//  HW1Visual
//
//  Created by Roy Hermann on 3/15/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import "LaplacianHistogram.h"

@interface LaplacianHistogram ()

//bin is set to 8 partitions, ranging from -2040 to +2040. For easier calculation, I will offset it by 2040

@property int maxHits;

@end

#define DIFFERENCE_THRESHOLD 750

@implementation LaplacianHistogram


-(id)initCustom{
    if(self=[super init]){
        //init bins
        _imageIndex  =0;
        _bins = [NSMutableArray new];
        for(int i=0;i<5;i++){
            [_bins addObject:@0];
        }
        
        //init arrays
        _mostSimilarHistograms = [[NSMutableArray alloc]initWithCapacity:3];
        _mostDifferentHistograms = [[NSMutableArray alloc]initWithCapacity:3];
        _comparedHistograms = [NSMutableDictionary new];
        _totalNumberOfPixels = 0;
        return self;
    }
    return nil;
    
}
-(void)addPixelValueToBin:(int)pixelValue{
    pixelValue += 2040;
    if(pixelValue <= 1325){
        //-2040 to -715
        int currentBinValue = [_bins[0]intValue]+1;
        _bins[0] = [NSNumber numberWithInt:currentBinValue];
    }
    else if(pixelValue <=1835){
        //-715 to -205
        int currentBinValue = [_bins[1]intValue]+1;
        _bins[1] = [NSNumber numberWithInt:currentBinValue];
    }
    else if(pixelValue <= 2245){
        //-205 to 205
        int currentBinValue = [_bins[2]intValue]+1;
        _bins[2] = [NSNumber numberWithInt:currentBinValue];
    }
    else if(pixelValue <= 2755){
        //205 to 715
        int currentBinValue = [_bins[3]intValue]+1;
        _bins[3] = [NSNumber numberWithInt:currentBinValue];
    }
    else{
        //715 to 2040
        int currentBinValue = [_bins[4]intValue]+1;
        _bins[4] = [NSNumber numberWithInt:currentBinValue];
    }
    _totalNumberOfPixels++;

}
#pragma mark - Comparison
-(NSMutableDictionary*)compareWithHistogram:(LaplacianHistogram*)b{
    if (self.imageIndex == b.imageIndex) return nil;
    
    int totalPixelsA = _totalNumberOfPixels;
    int totalPixelsB = b.totalNumberOfPixels;
    
    double difference = 0.0;
    
    //L1 difference calcuation
    for(int i=0;i<self.bins.count;i++){
        double normalizedGreenBinA = [self.bins[i]doubleValue] / totalPixelsA;
        double normalizedGreenBinB = [b.bins[i]doubleValue] / totalPixelsB;
        double calc = normalizedGreenBinA - normalizedGreenBinB;
        if(calc < 0) {
            calc = calc * -1;
        }
        difference += calc;
    }
    
    difference = difference/2; //divide by number of camparitors
    
    double similarity = 1 - difference;
    [_comparedHistograms setObject:[NSNumber numberWithDouble:similarity] forKey:[NSString stringWithFormat:@"%i",b.imageIndex]];
    
    return _comparedHistograms;
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

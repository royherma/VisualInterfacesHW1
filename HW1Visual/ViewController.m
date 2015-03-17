//
//  ViewController.m
//  HW1Visual
//
//  Created by Roy Hermann on 2/15/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "MultiDimensionalHistogram.h"
#import "LaplacianHistogram.h"
#import "ClusterCell.h"
#import "InfoDisplayTableViewCell.h"
#import "ComparisonTester.h"


@interface ViewController ()

@property UIImage *originalImage;
@property UIButton *activeButton;
@property NSString *savedPasswordCombination1;
@property NSString *savedPasswordCombination2;
@property NSMutableArray *namesOfImages;
@property int counter;
@property NSMutableArray *histograms;
@property NSMutableArray *laplacianHistograms;
@property NSMutableArray *combinedSimilarities;
@property NSMutableArray *distanceArray;
@property NSMutableArray *part1MostSimilar;
@property NSMutableArray *part1MostDifferent;
@property NSMutableArray *part2MostSimilar;
@property NSMutableArray *part2MostDifferent;
@property NSMutableArray *sharedClusters;



//for tableview
@property NSMutableArray *imageNames;


@end

BOOL createPassword,part1isSet;

#define MIN_THRESHOLD_WHITE_PIXELS_FOR_FIVE 150
#define MAX_THESHOLD_WHITE_PIXELS_FOR_FIST 125
// 1.
#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )

//Macros for neighbors calculation
#define MIN_WIDTH 0
#define MIN_HEIGHT 0
#define MAX_WIDTH 88
#define MAX_HEIGHT 59

BOOL SHOW_CLUSTERS;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //for testing against preset password
    SHOW_CLUSTERS = YES;

    _imageNames = [NSMutableArray new];
    _namesOfImages = [NSMutableArray new];
    //part 1
    _histograms = [NSMutableArray new];
    //part 2
    _laplacianHistograms = [NSMutableArray new];
    //part 3
    _combinedSimilarities = [NSMutableArray new];
    _distanceArray = [NSMutableArray new];
    for(int i=0;i<40;i++){
        [_distanceArray addObject:[NSMutableArray arrayWithCapacity:40]];
    }
    
    
    NSString *imgName;
    for(int i=1;i<41;i++){
        if(i<10)
            imgName = [NSString stringWithFormat:@"i0%i.jpg",i];
        else
            imgName = [NSString stringWithFormat:@"i%i.jpg",i];
        [_namesOfImages addObject:imgName];
        
        //create histogram for each image
        MultiDimensionalHistogram *histogram = [[MultiDimensionalHistogram alloc]initProperties];
        histogram.imageIndex = i;
        [_histograms addObject:histogram];
        
        //create laplacian histogram for each image
        LaplacianHistogram *laplacianHistogram = [[LaplacianHistogram alloc]initCustom];
        laplacianHistogram.imageIndex = i;
        [_laplacianHistograms addObject:laplacianHistogram];
    }


    
    _counter = 0;
    

    [self assignment2];
    
    
    


}
#pragma mark - Assignment 2
-(void)assignment2{
    _counter = 0;
    
    //Part 1
//    [self grossColorComparison];
//    [self getStatsForPart1];
//        [self.tableView reloadData];
    
    //Part 2
//        [self toGrayScaleAndLaplacian];
//        [self getStatsForPart2];
//        [self.tableView reloadData];
    
    //part 3
    [self grossColorComparison];
    [self getStatsForPart1];
    _counter = 0;
    [self toGrayScaleAndLaplacian];
    [self getStatsForPart2];
    [self getStatsForPart3];
    
    //part 4
//    [self addFriendsResultsForColor];
//    [self addFriendsResultsForTexture];
    [self addFriendsResultsForClusters];
//    [self.tableView reloadData];
}
#pragma mark - Part4
-(void)addFriendsResultsForClusters{
    NSArray *eden = @[@[@1,@10,@16,@13,@14],
                      @[@2,@15,@12],
                      @[@3,@4,@39,@36,@19,@24,@37,@7,@40,@8,@9],
                      @[@5,@11,@6,@26],
                      @[@17,@20,@35,@18,@21,@38,@29,@30],
                      @[@22],
                      @[@23,@33,@25,@28,@27,@34,@31,@32]];
    
    NSArray *gideon = @[@[@36,@16,@10,@13,@14,@4,@8,@37],
                        @[@2,@15,@12],
                        @[@3,@1,@9,@39,@19,@24,@38,@11,@28,@32],
                        @[@5,@25,@6,@7,@40,@33],
                        @[@17,@23,@21,@18,@35,@20,@27,@31],
                        @[@22,@34,@29,@30],
                        @[@26]];
    
    NSArray *daniel = @[@[@1,@13,@10,@19,@14,@3,@28,@8,@37],
                       @[@2,@15,@12],
                        @[@5,@40,@7,@11,@33,@6,@23,@20],
                        @[@9,@39,@34,@24,@38,@4,@32,@22,@29,@30],
                        @[@17,@25,@21,@16,@18,@35],
                        @[@26,@36],
                        @[@27,@31]];
    
    
    _imageNames = [NSMutableArray arrayWithArray:eden];
    ComparisonTester *ct = [[ComparisonTester alloc]initCustom];
    ct.imageClusterMatchingResults = _sharedClusters;
    double score = [ct getScoreForUserChosenClusterMatches:[NSMutableArray arrayWithArray:daniel]];
    NSLog(@"cluster score - %f",score);
    
}
-(void)addFriendsResultsForColor{
    NSArray *edenDiff = @[@23,
                      @25,
                      @26,
                      @31,
                      @29,
                      @3,
                      @29,
                      @26,
                      @3,
                      @6,
                      @3,
                      @22,
                      @6,
                      @6,
                      @29,
                      @6,
                      @29,
                      @29,
                      @31,
                      @29,
                      @31,
                      @31,
                      @29,
                      @31,
                      @29,
                      @12,
                      @6,
                      @29,
                      @23,
                      @6,
                      @22,
                      @18,
                      @22,
                      @31,
                      @29,
                      @31,
                      @23,
                      @31,
                      @29,
                      @3];
    
    NSArray *gidiDiff = @[@6,
                      @29,
                      @23,
                      @23,
                      @3,
                      @27,
                      @4,
                      @23,
                      @29,
                      @23,
                      @29,
                      @4,
                      @23,
                      @26,
                      @4,
                      @23,
                      @22,
                      @22,
                      @23,
                      @37,
                      @29,
                      @33,
                      @22,
                      @33,
                      @26,
                      @22,
                      @23,
                      @30,
                      @26,
                      @33,
                      @29,
                      @12,
                      @29,
                      @2,
                      @22,
                      @23,
                      @6,
                      @33,
                      @26,
                      @22];
    NSArray *danielDiff = @[
                        @31,
                        @30,
                        @33,
                        @33,
                        @22,
                        @22,
                        @22,
                        @29,
                        @26,
                        @25,
                        @22,
                        @25,
                        @33,
                        @23,
                        @37,
                        @33,
                        @30,
                        @6,
                        @29,
                        @30,
                        @33,
                        @23,
                        @37,
                        @23,
                        @30,
                        @25,
                        @29,
                        @31,
                        @35,
                        @12,
                        @34,
                        @35,
                        @30,
                        @2,
                        @30,
                        @2,
                        @33,
                        @23,
                        @6,
                        @29];
    
    NSArray *edenSimilar = @[@4,
                             @28,
                             @24,
                             @3,
                             @40,
                             @5,
                             @15,
                             @24,
                             @39,
                             @16,
                             @9,
                             @7,
                             @10,
                             @1,
                             @7,
                             @10,
                             @25,
                             @35,
                             @4,
                             @35,
                             @25,
                             @38,
                             @40,
                             @8,
                             @17,
                             @28,
                             @30,
                             @2,
                             @30,
                             @29,
                             @23,
                             @3,
                             @40,
                             @36,
                             @18,
                             @38,
                             @4,
                             @36,
                             @24,
                             @7];
    
    NSArray *gidiSimilar = @[@3,
                             @24,
                             @4,
                             @19,
                             @6,
                             @40,
                             @40,
                             @4,
                             @3,
                             @1,
                             @7,
                             @40,
                             @16,
                             @19,
                             @2,
                             @1,
                             @21,
                             @17,
                             @8,
                             @40,
                             @2,
                             @36,
                             @5,
                             @3,
                             @21,
                             @5,
                             @13,
                             @40,
                             @34,
                             @27,
                             @11,
                             @9,
                             @5,
                             @38,
                             @20,
                             @3,
                             @3,
                             @3,
                             @8,
                             @33];
    
    NSArray *danielSimilar = @[@16,
                               @15,
                               @36,
                               @24,
                               @23,
                               @7,
                               @11,
                               @3,
                               @11,
                               @13,
                               @40,
                               @33,
                               @1,
                               @3,
                               @40,
                               @13,
                               @2,
                               @25,
                               @3,
                               @23,
                               @17,
                               @34,
                               @28,
                               @36,
                               @2,
                               @35,
                               @10,
                               @5,
                               @10,
                               @13,
                               @40,
                               @5,
                               @7,
                               @2,
                               @23,
                               @24,
                               @24,
                               @24,
                               @38,
                               @28];
    
    NSMutableArray *friendsSimAndDiff = [NSMutableArray new];
    for (int i=0; i<40; i++) {
        NSMutableArray *row = [NSMutableArray new];
        [row addObject:[NSNumber numberWithInt:i+1]];
        [row addObject:edenSimilar[i]];
        [row addObject:danielSimilar[i]];
        [row addObject:gidiSimilar[i]];
        [row addObject:gidiDiff[i]];
        [row addObject:edenDiff[i]];
        [row addObject:danielDiff[i]];
        [friendsSimAndDiff addObject:row];
    }
    _imageNames = friendsSimAndDiff;

    
    
    
    ///tester for checking system accuracy.
    //part 1
    NSMutableArray *mostSimilarColor = [NSMutableArray new];
    NSLog(@"-- most similar --");
    for(int i=0;i<_histograms.count;i++){
        //compare all histograms to this one
        MultiDimensionalHistogram *h = _histograms[i];
        for(int j=0;j<_histograms.count;j++){
            [h compareWithHistogram:_histograms[j]];
        }
        
        NSArray *descendingArray = [h sortArrayDescending];
        NSString *a = [NSString stringWithFormat:@"%i",[descendingArray[0] intValue]];
        NSString *b = [NSString stringWithFormat:@"%i",[descendingArray[1] intValue]];
        NSString *c = [NSString stringWithFormat:@"%i",[descendingArray[2] intValue]];
        
        double h1 = [[h.comparedHistograms objectForKey:a] doubleValue];
        double h2 = [[h.comparedHistograms objectForKey:b]doubleValue];
        double h3 = [[h.comparedHistograms objectForKey:c]doubleValue];
        
        NSLog(@",%i,%@,%.2f,%@,%.2f,%@,%.2f",i+1,a,h1,b,h2,c,h3);
        
        
        [mostSimilarColor addObject:[NSMutableArray arrayWithObjects:descendingArray[0],descendingArray[1],descendingArray[2], nil]];
        
    }
    ComparisonTester *ct = [[ComparisonTester alloc]initCustom];
    ct.colorHistograms = _histograms;
    double score =[ct getScoreFromSystemMatches:mostSimilarColor andUserMatches:[NSMutableArray arrayWithArray:edenSimilar]];
    NSLog(@"eden score = %.2f",score);
    score =[ct getScoreFromSystemMatches:mostSimilarColor andUserMatches:[NSMutableArray arrayWithArray:gidiSimilar]];
    NSLog(@"gidi score = %.2f",score);
    score =[ct getScoreFromSystemMatches:mostSimilarColor andUserMatches:[NSMutableArray arrayWithArray:danielSimilar]];
    NSLog(@"daniel score = %.2f",score);
    NSLog(@"overall score = %.2f",ct.overallScore);
    
}
-(void)addFriendsResultsForTexture{
    NSArray *edenDiff = @[@16,
                          @18,
                          @6,
                          @6,
                          @18,
                          @16,
                          @17,
                          @17,
                          @18,
                          @6,
                          @16,
                          @18,
                          @17,
                          @17,
                          @18,
                          @18,
                          @6,
                          @3,
                          @6,
                          @5,
                          @6,
                          @6,
                          @18,
                          @16,
                          @6,
                          @18,
                          @6,
                          @16,
                          @6,
                          @6,
                          @6,
                          @16,
                          @18,
                          @6,
                          @33,
                          @6,
                          @6,
                          @33,
                          @6,
                          @18];
    NSArray *gidiDiff = @[@18,
                          @17,
                          @2,
                          @2,
                          @17,
                          @18,
                          @17,
                          @6,
                          @6,
                          @18,
                          @17,
                          @18,
                          @17,
                          @18,
                          @19,
                          @19,
                          @2,
                          @2,
                          @2,
                          @2,
                          @2,
                          @2,
                          @6,
                          @2,
                          @2,
                          @17,
                          @15,
                          @15,
                          @16,
                          @16,
                          @2,
                          @2,
                          @17,
                          @2,
                          @14,
                          @14,
                          @14,
                          @2,
                          @2,
                          @17];
    
    NSArray *danielDiff = @[@40,
                            @38,
                            @11,
                            @18,
                            @40,
                            @38,
                            @38,
                            @17,
                            @17,
                            @17,
                            @38,
                            @40,
                            @49,
                            @38,
                            @49,
                            @38,
                            @25,
                            @25,
                            @26,
                            @25,
                            @26,
                            @25,
                            @2,
                            @26,
                            @25,
                            @39,
                            @26,
                            @25,
                            @26,
                            @26,
                            @18,
                            @26,
                            @39,
                            @26,
                            @26,
                            @26,
                            @18,
                            @26,
                            @11,
                            @39];
    
    NSArray *edenSimilar = @[@13,
                             @6,
                             @39,
                             @3,
                             @12,
                             @2,
                             @14,
                             @16,
                             @16,
                             @8,
                             @5,
                             @2,
                             @1,
                             @40,
                             @5,
                             @8,
                             @38,
                             @17,
                             @35,
                             @24,
                             @22,
                             @21,
                             @31,
                             @20,
                             @36,
                             @15,
                             @34,
                             @24,
                             @22,
                             @35,
                             @23,
                             @28,
                             @23,
                             @27,
                             @19,
                             @25,
                             @39,
                             @17,
                             @3,
                             @14];
    
    NSArray *gidiSimilar = @[@16,
                             @6,
                             @4,
                             @39,
                             @15,
                             @11,
                             @40,
                             @10,
                             @8,
                             @16,
                             @12,
                             @5,
                             @16,
                             @7,
                             @12,
                             @9,
                             @21,
                             @38,
                             @30,
                             @30,
                             @38,
                             @29,
                             @33,
                             @30,
                             @28,
                             @12,
                             @4,
                             @36,
                             @30,
                             @29,
                             @33,
                             @36,
                             @31,
                             @28,
                             @30,
                             @28,
                             @4,
                             @22,
                             @4,
                             @7];
    
    NSArray *danielSimilar = @[@8,
                               @11,
                               @27,
                               @37,
                               @11,
                               @12,
                               @9,
                               @9,
                               @10,
                               @9,
                               @2,
                               @15,
                               @14,
                               @16,
                               @26,
                               @1,
                               @22,
                               @21,
                               @24,
                               @35,
                               @29,
                               @38,
                               @37,
                               @19,
                               @20,
                               @2,
                               @39,
                               @32,
                               @21,
                               @24,
                               @37,
                               @19,
                               @37,
                               @36,
                               @29,
                               @20,
                               @3,
                               @22,
                               @37,
                               @16];
    
    NSMutableArray *friendsSimAndDiff = [NSMutableArray new];
    for (int i=0; i<40; i++) {
        NSMutableArray *row = [NSMutableArray new];
        [row addObject:[NSNumber numberWithInt:i+1]];
        [row addObject:edenSimilar[i]];
        [row addObject:danielSimilar[i]];
        [row addObject:gidiSimilar[i]];
        [row addObject:gidiDiff[i]];
        [row addObject:edenDiff[i]];
        [row addObject:danielDiff[i]];
        [friendsSimAndDiff addObject:row];
    }
    _imageNames = friendsSimAndDiff;
    
    
    ///tester for checking system accuracy.
    //part 1
    NSMutableArray *mostSimilarColor = [NSMutableArray new];
    NSLog(@"-- most similar --");
    for(int i=0;i<_laplacianHistograms.count;i++){
        //compare all histograms to this one
        LaplacianHistogram *h = _laplacianHistograms[i];
        for(int j=0;j<_laplacianHistograms.count;j++){
            [h compareWithHistogram:_laplacianHistograms[j]];
        }
        
        NSArray *descendingArray = [h sortArrayDescending];
        NSString *a = [NSString stringWithFormat:@"%i",[descendingArray[0] intValue]];
        NSString *b = [NSString stringWithFormat:@"%i",[descendingArray[1] intValue]];
        NSString *c = [NSString stringWithFormat:@"%i",[descendingArray[2] intValue]];
        
        double h1 = [[h.comparedHistograms objectForKey:a] doubleValue];
        double h2 = [[h.comparedHistograms objectForKey:b]doubleValue];
        double h3 = [[h.comparedHistograms objectForKey:c]doubleValue];
        
        NSLog(@",%i,%@,%.2f,%@,%.2f,%@,%.2f",i+1,a,h1,b,h2,c,h3);
        
        
        [mostSimilarColor addObject:[NSMutableArray arrayWithObjects:descendingArray[0],descendingArray[1],descendingArray[2], nil]];
        
    }
    ComparisonTester *ct = [[ComparisonTester alloc]initCustom];
    double score =[ct getScoreFromSystemMatches:mostSimilarColor andUserMatches:[NSMutableArray arrayWithArray:edenSimilar]];
    NSLog(@"eden score = %.2f",score);
    score =[ct getScoreFromSystemMatches:mostSimilarColor andUserMatches:[NSMutableArray arrayWithArray:gidiSimilar]];
    NSLog(@"gidi score = %.2f",score);
    score =[ct getScoreFromSystemMatches:mostSimilarColor andUserMatches:[NSMutableArray arrayWithArray:danielSimilar]];
    NSLog(@"daniel score = %.2f",score);
    NSLog(@"overall score = %.2f",ct.overallScore);
    
    
    
}
#pragma mark - Part3
-(void)getStatsForPart3{
    
    //create 2d array with combined simiilarities
    for(int i=0;i<40;i++){
        NSMutableArray *comparisonArray = [NSMutableArray new];
        for(int j=0;j<40;j++){
            if(i!=j){
                
                MultiDimensionalHistogram *mdh = _histograms[i];
                LaplacianHistogram *lph = _laplacianHistograms[i];
                NSString *strImgName = [NSString stringWithFormat:@"%i",j+1];
                double mdhSim = [[mdh.comparedHistograms objectForKey:strImgName] doubleValue];
                double lphSim = [[lph.comparedHistograms objectForKey:strImgName] doubleValue];
                double similarity = (0.8 * mdhSim + 0.2 * lphSim);
                double distance = 1 - similarity;
                NSLog(@"joint distance between img %i and img %i is %f",i+1,j+1,distance);
                [comparisonArray addObject:[NSNumber numberWithDouble:distance]];
            }else{
                [comparisonArray addObject:@0.0];
            }
        }
        //adding to 2d array column
        [_combinedSimilarities addObject:comparisonArray];
    }
    

    [self completeLinkClusters];
    [self singleLinkClusters];
    
}
-(void)completeLinkClusters{
    NSLog(@"COMPLETE LINK CLUSTER");
    //create array of 40 for each image
    NSMutableArray *clusters = [NSMutableArray new];
    for(int i=1;i<41;i++){
        [clusters addObject:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%i",i]]];
    }
    
    //cluster until there are 7 clusters
    while(clusters.count > 7){
        
        //create a 2d array that holds the nearness between each cluster
        NSMutableArray *distances = [NSMutableArray new];
        for(int i=0;i<clusters.count;i++){
            [distances addObject:[NSMutableArray new]];
            for(int j=0;j<clusters.count;j++){
                [distances[i] addObject:[NSNull null]];
            }
        }
        
        
        
        
        //for each of the clusters, find distance between all other clusters using pairwise comparison
        for(int i=0;i<clusters.count;i++){
            //grab cluster A
            NSMutableArray *clusterA = clusters[i];
            //grab another cluster
            for(int j=0;j<clusters.count;j++){
                if(i!=j){
                    //make sure we are not comparing the same clusters
                    NSMutableArray *clusterB = clusters[j];
                    
                    NSMutableDictionary *distancesFromClusterA = [NSMutableDictionary new];
                    double farthestDistance = 0.0;
                    for(int k=0;k<clusterA.count;k++){
                        NSString *imgA = clusterA[k];
                        for(int l=0;l<clusterB.count;l++){
                            NSString *imgB = clusterB[l];
                            int adjustedA = [imgA intValue]-1;
                            int adjustedB = [imgB intValue]-1;
                            double distance = [_combinedSimilarities[adjustedA][adjustedB]doubleValue];
                            if(distance>farthestDistance) farthestDistance = distance;
                            //                            NSLog(@"distance between img %@ and img %@ = %.2f",imgA,imgB,distance);
                            [distancesFromClusterA setObject:[NSNumber numberWithDouble:distance] forKey:imgB];
                        }
                    }
                    //add to cluster distances hashtable
                    distances[i][j] = [NSNumber numberWithDouble:farthestDistance];
                    distances[j][i] = [NSNumber numberWithDouble:farthestDistance];
                }
                else{
                    //add to cluster distances hashtable
                    distances[i][j] = @0.0;
                    distances[j][i] = @0.0;
                }
            }
        }
        //        [self print2dArray:distances];
        //now combine two clusters that have lowest distance from eachother
        int col=0;
        int row=0;
        double min = 1.0;
        for(int i=0;i<distances.count;i++){
            for(int j=0;j<distances.count;j++){
                if(i!=j) {
                    double val = [distances[i][j]doubleValue];
                    if(val<min){
                        min = val;
                        col = i;
                        row = j;
                    }
                }
            }
        }
        //join both clusters
        NSMutableArray *clusterA = clusters[col];
        NSMutableArray *clusterB = clusters[row];
        [clusterA addObjectsFromArray:clusterB];
        [clusters removeObject:clusterB];
        
    }
    
    //print clusters
    for(int i=0;i<clusters.count;i++){
        NSMutableArray *cluster = clusters[i];
        NSString *line = @",{,";
        for(int j=0;j<cluster.count;j++){
            line = [[line stringByAppendingString:cluster[j]]stringByAppendingString:@","];
        }
        line = [line stringByAppendingString:@"}"];
        NSLog(@"%@",line);
    }
    
    //to access from other locations
    _sharedClusters = clusters;
    
//    _imageNames = clusters;
}
-(void)singleLinkClusters{
    NSLog(@"Daniel's Clusters");
    //create array of 40 for each image
    NSMutableArray *clusters = [NSMutableArray new];
    for(int i=1;i<41;i++){
        [clusters addObject:[NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%i",i]]];
    }
    
    //cluster until there are 7 clusters
    while(clusters.count > 7){
        
        //create a 2d array that holds the nearness between each cluster
        NSMutableArray *distances = [NSMutableArray new];
        for(int i=0;i<clusters.count;i++){
            [distances addObject:[NSMutableArray new]];
            for(int j=0;j<clusters.count;j++){
                [distances[i] addObject:[NSNull null]];
            }
        }
        
        
        
        
        //for each of the clusters, find pairwise ditsnace between all other clusters
        for(int i=0;i<clusters.count;i++){
            //grab cluster A
            NSMutableArray *clusterA = clusters[i];
            //grab another cluster
            for(int j=0;j<clusters.count;j++){
                if(i!=j){
                    //make sure we are not comparing the same clusters
                    NSMutableArray *clusterB = clusters[j];
                    
                    NSMutableDictionary *distancesFromClusterA = [NSMutableDictionary new];
                    double closestDistance = 1.0;
                    for(int k=0;k<clusterA.count;k++){
                        NSString *imgA = clusterA[k];
                        for(int l=0;l<clusterB.count;l++){
                            NSString *imgB = clusterB[l];
                            int adjustedA = [imgA intValue]-1;
                            int adjustedB = [imgB intValue]-1;
                            double distance = [_combinedSimilarities[adjustedA][adjustedB]doubleValue];
                            if(distance<closestDistance) closestDistance = distance;
                            //                            NSLog(@"distance between img %@ and img %@ = %.2f",imgA,imgB,distance);
                            [distancesFromClusterA setObject:[NSNumber numberWithDouble:distance] forKey:imgB];
                        }
                    }
                    //add to cluster distances hashtable
                    distances[i][j] = [NSNumber numberWithDouble:closestDistance];
                    distances[j][i] = [NSNumber numberWithDouble:closestDistance];
                }
                else{
                    //add to cluster distances hashtable
                    distances[i][j] = @0.0;
                    distances[j][i] = @0.0;
                }
            }
        }
        //        [self print2dArray:distances];
        //now combine two clusters that have farthest distance from eachother
        int col=0;
        int row=0;
        double max = 0.0;
        for(int i=0;i<distances.count;i++){
            for(int j=0;j<distances.count;j++){
                if(i!=j) {
                    double val = [distances[i][j]doubleValue];
                    if(val>max){
                        max = val;
                        col = i;
                        row = j;
                    }
                }
            }
        }
        //join both clusters
        NSMutableArray *clusterA = clusters[col];
        NSMutableArray *clusterB = clusters[row];
        [clusterA addObjectsFromArray:clusterB];
        [clusters removeObject:clusterB];
        
    }
    
    //print clusters
    for(int i=0;i<clusters.count;i++){
        NSMutableArray *cluster = clusters[i];
        NSString *line = @"{";
        for(int j=0;j<cluster.count;j++){
            line = [[line stringByAppendingString:cluster[j]]stringByAppendingString:@" "];
        }
        line = [line stringByAppendingString:@"}"];
        NSLog(@"%@",line);
    }
    _imageNames = clusters;
}
#pragma mark - Part2
-(void)toGrayScaleAndLaplacian{
    
    if(_counter == _namesOfImages.count) {

        return;
    }
    
    //setup image
//    NSLog(@"laplating image %i",_counter);
    self.imageView.image = [UIImage imageNamed:_namesOfImages[_counter]];
    UIImage *inputImage = self.imageView.image;
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    
    
    GPUImageGrayscaleFilter *stillImageFilter = [[GPUImageGrayscaleFilter alloc]init];
    
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    //get grayscaled image
    UIImage *grayScaledImage = [stillImageFilter imageFromCurrentFramebuffer];
    self.imageView.image = grayScaledImage;
    
    //1. start exporting pixel info indivually
    CGImageRef inputCGImage = [self.imageView.image CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    // 2.
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 * pixels;
    pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    
    // 3.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 4.
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    // 5. Cleanup
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    //create array for pixels (89x60) to store pixel info
    NSMutableArray *widthPixelArray = [NSMutableArray new];
    for(int i=0;i<89;i++)
        [widthPixelArray addObject:[NSMutableArray arrayWithCapacity:60]];

    //
    for (NSUInteger w = 0; w < width; w++) {
        //reset bool variable for each row
        for (NSUInteger l = 0; l < height; l++) {
            UInt32 color = *pixels;
//            NSLog(@"pixels[%i][%i]- r=%u g=%u b=%u", (int)w,(int)l,R(color),G(color),B(color));
            widthPixelArray[w][l] = [NSNumber numberWithInt:(R(color)+G(color)+B(color))];
            pixels++;
            
            //print pixel value from array
//            NSLog(@"widthPixelArray[%i][%i] sum = %i",(int)w,(int)l,[widthPixelArray[w][l]intValue]);
        }
    }
    
    //create array for pixels (89x60)
    NSMutableArray *adjustedWidthPixelArray = [NSMutableArray new];
    for(int i=0;i<89;i++)
        [adjustedWidthPixelArray addObject:[NSMutableArray arrayWithCapacity:60]];
    
    


    //get histogram for image
    LaplacianHistogram *lh = _laplacianHistograms[_counter];
    for (NSUInteger w = 0; w < width; w++) {
        //reset bool variable for each row
        for (NSUInteger l = 0; l < height; l++) {
            int originalPixelValue = [widthPixelArray[w][l]intValue];
            //handeling of bg
            if(originalPixelValue > 10){
                
                int startPosX = ((int)(w - 1) < MIN_WIDTH) ? (int)w : (int)w-1;
                int startPosY = ((int)(l - 1) < MIN_HEIGHT) ? (int)l : (int)l-1;
                int endPosX =   ((int)(w + 1) > MAX_WIDTH) ? (int)w : (int)w+1;
                int endPosY =   ((int)(l + 1) > MAX_HEIGHT) ? (int)l : (int)l+1;
                
                // Calculate neighbors sum
    //            NSLog(@"getting neighbors pixel value for pixel [%i][%i]",(int)w,(int)l);


                int sum =0;
                int neighbors= 0;
                for (int colNum=startPosX; colNum<=endPosX; colNum++) {
                    for (int rowNum=startPosY; rowNum<=endPosY; rowNum++) {
                        // All the neighbors will be grid[rowNum][colNum]
                        if((colNum != w || rowNum != l)){
                            sum += [widthPixelArray[colNum][rowNum]intValue];
    //                         NSLog(@"subtracting neighboring pixel @ [%i][%i], value = %i ",colNum,rowNum,sum);
                        neighbors++;
                        }

                    }
                }
            
                int adjustedPixelValue = ([widthPixelArray[w][l]intValue] * neighbors) - sum;

                //add pixel info to histogram/bin
                [lh addPixelValueToBin:adjustedPixelValue];
            }
            else{
                //ignore because is considered bg
            }
        }
    }
    

    
    

    //new array with adjusted pixel values
    _counter++;
    [self toGrayScaleAndLaplacian];
    
    
    
}
-(void)getStatsForPart2{
    //all images have been processed
    
    _part2MostSimilar = [NSMutableArray new];
    _part2MostDifferent = [NSMutableArray new];
    
    NSLog(@"-- most similar --");
    for(int i=0;i<_laplacianHistograms.count;i++){
        //compare all histograms to this one
        LaplacianHistogram *h = _laplacianHistograms[i];
        for(int j=0;j<_laplacianHistograms.count;j++){
            [h compareWithHistogram:_laplacianHistograms[j]];
        }
        NSArray *descendingArray = [h sortArrayDescending];
        
        NSString *a = [NSString stringWithFormat:@"%i",[descendingArray[0] intValue]];
        NSString *b = [NSString stringWithFormat:@"%i",[descendingArray[1] intValue]];
        NSString *c = [NSString stringWithFormat:@"%i",[descendingArray[2] intValue]];
        
        double h1 = [[h.comparedHistograms objectForKey:a] doubleValue];
        double h2 = [[h.comparedHistograms objectForKey:b]doubleValue];
        double h3 = [[h.comparedHistograms objectForKey:c]doubleValue];
        double average = (h1+h2+h3)/3;
        [_part2MostSimilar addObject:[NSNumber numberWithDouble:average]];
        
        NSLog(@",%i,%@,%.2f,%@,%.2f,%@,%.2f",i+1,a,h1,b,h2,c,h3);
    }
    NSLog(@"--  Most different --");
    for(int i=0;i<_laplacianHistograms.count;i++){
        //compare all histograms to this one
        LaplacianHistogram *h = _laplacianHistograms[i];
        for(int j=0;j<_laplacianHistograms.count;j++){
            [h compareWithHistogram:_laplacianHistograms[j]];
        }

        NSArray *descendingArray = [h sortArrayDescending];
        int size = (int)descendingArray.count;
        
        NSString *d = [NSString stringWithFormat:@"%i",[descendingArray[size-1] intValue]];
        NSString *e = [NSString stringWithFormat:@"%i",[descendingArray[size-2] intValue]];
        NSString *f = [NSString stringWithFormat:@"%i",[descendingArray[size-3] intValue]];

        double h4 = [[h.comparedHistograms objectForKey:d] doubleValue];
        double h5 = [[h.comparedHistograms objectForKey:e]doubleValue];
        double h6 = [[h.comparedHistograms objectForKey:f]doubleValue];
        double average = (h4+h5+h6)/3;
        [_part2MostDifferent addObject:[NSNumber numberWithDouble:average]];
        NSLog(@",%i,%@,%.2f,%@,%.2f,%@,%.2f",i+1,d,h4,e,h5,f,h6);
    }
    
    //finding index of most different and most similar
    int indexMostSim = 0;
    double mostSim = [_part2MostSimilar[0] doubleValue];
    
    for(int i=1;i<_part2MostSimilar.count;i++){
        if([_part2MostSimilar[i]doubleValue ] > mostSim){
            indexMostSim = i;
            mostSim = [_part2MostSimilar[i]doubleValue];
        }
    }
    NSLog(@"most similar texture is for img %i with difference average of %.2f",indexMostSim+1,mostSim);
    
    int indexMostDif = 0;
    double mostDif = [_part2MostDifferent[0] doubleValue];
    
    for(int i=1;i<_part2MostDifferent.count;i++){
        if([_part2MostDifferent[i]doubleValue ] > mostSim){
            indexMostSim = i;
            mostSim = [_part2MostDifferent[i]doubleValue];
        }
    }
    NSLog(@"most different texture is for img %i with difference average of %.2f",indexMostDif+1,mostDif);
    
    //for tableview
    for(int i=0;i<_laplacianHistograms.count;i++){
        NSMutableArray *forTableView = [NSMutableArray new];
        LaplacianHistogram *h = _laplacianHistograms[i];
        NSArray *descendingArray = [h sortArrayDescending];
        
        
        //root image
        [forTableView addObject:[NSNumber numberWithInt:i+1]];
        //most similar
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[0] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[1] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[2] intValue]]];
        //most different
        int size = (int)descendingArray.count;
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[size-1] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[size-2] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[size-3] intValue]]];
        
        [_imageNames addObject:forTableView];
        
    }

}
#pragma mark - Part1
-(void)getStatsForPart1{
    //all images have been processed
    
    _part1MostSimilar = [NSMutableArray new];
    _part1MostDifferent = [NSMutableArray new];
    

    
    NSLog(@"-- most similar --");
    for(int i=0;i<_histograms.count;i++){
        //compare all histograms to this one
        MultiDimensionalHistogram *h = _histograms[i];
        for(int j=0;j<_histograms.count;j++){
            [h compareWithHistogram:_histograms[j]];
        }
        
        NSArray *descendingArray = [h sortArrayDescending];
        

        NSString *a = [NSString stringWithFormat:@"%i",[descendingArray[0] intValue]];
        NSString *b = [NSString stringWithFormat:@"%i",[descendingArray[1] intValue]];
        NSString *c = [NSString stringWithFormat:@"%i",[descendingArray[2] intValue]];

        double h1 = [[h.comparedHistograms objectForKey:a] doubleValue];
        double h2 = [[h.comparedHistograms objectForKey:b]doubleValue];
        double h3 = [[h.comparedHistograms objectForKey:c]doubleValue];
        double average = (h1+h2+h3)/3;
        [_part1MostSimilar addObject:[NSNumber numberWithDouble:average]];

        NSLog(@",%i,%@,%.2f,%@,%.2f,%@,%.2f",i+1,a,h1,b,h2,c,h3);
        

    }
    
    NSLog(@"-- most different --");
    for(int i=0;i<_histograms.count;i++){
        //compare all histograms to this one
        MultiDimensionalHistogram *h = _histograms[i];
        for(int j=0;j<_histograms.count;j++){
            [h compareWithHistogram:_histograms[j]];
        }
        
        NSArray *descendingArray = [h sortArrayDescending];

        int size = (int)descendingArray.count;
        NSString *d = [NSString stringWithFormat:@"%i",[descendingArray[size-1] intValue]];
        NSString *e = [NSString stringWithFormat:@"%i",[descendingArray[size-2] intValue]];
        NSString *f = [NSString stringWithFormat:@"%i",[descendingArray[size-3] intValue]];
        
        double h4 = [[h.comparedHistograms objectForKey:d] doubleValue];
        double h5 = [[h.comparedHistograms objectForKey:e]doubleValue];
        double h6 = [[h.comparedHistograms objectForKey:f]doubleValue];
        double average = (h4+h5+h6)/3;
        [_part1MostDifferent addObject:[NSNumber numberWithDouble:average]];
        NSLog(@",%i,%@,%.2f,%@,%.2f,%@,%.2f",i+1,d,h4,e,h5,f,h6);
        
        //for tableview
        

    }
    
    
    
    //for tableview
    for(int i=0;i<_histograms.count;i++){
        NSMutableArray *forTableView = [NSMutableArray new];
        MultiDimensionalHistogram *h = _histograms[i];
        NSArray *descendingArray = [h sortArrayDescending];
        
        
        //root image
        [forTableView addObject:[NSNumber numberWithInt:i+1]];
        //most similar
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[0] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[1] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[2] intValue]]];
        //most different
        int size = (int)descendingArray.count;
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[size-1] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[size-2] intValue]]];
        [forTableView addObject:[NSNumber numberWithInt:[descendingArray[size-3] intValue]]];
        
        [_imageNames addObject:forTableView];

    }
    

    
    //finding index of most different and most similar
    int indexMostSim = 0;
    double mostSim = [_part1MostSimilar[0] doubleValue];

    for(int i=1;i<_part1MostSimilar.count;i++){
        if([_part1MostSimilar[i]doubleValue ] > mostSim){
            indexMostSim = i;
            mostSim = [_part1MostSimilar[i]doubleValue];
        }
    }
    NSLog(@"most similar color comparison is for img %i with difference average of %.2f",indexMostSim+1,mostSim);
    
    int indexMostDif = 0;
    double mostDif = [_part1MostDifferent[0] doubleValue];
    
    for(int i=1;i<_part1MostDifferent.count;i++){
        if([_part1MostDifferent[i]doubleValue ] > mostSim){
            indexMostSim = i;
            mostSim = [_part1MostDifferent[i]doubleValue];
        }
    }
    NSLog(@"most different color comparison is for img %i with difference average of %.2f",indexMostDif+1,mostDif);
    
    

}
-(void)grossColorComparison{
    //when counter reaches end, all images have been processed
    if(_counter == _namesOfImages.count) {
        return;
    }
    
    self.imageView.image = [UIImage imageNamed:_namesOfImages[_counter]];
    UIImage *image = self.imageView.image;
    CGImageRef inputCGImage = [image CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    // 2.
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 * pixels;
    pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    
    // 3.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 4.
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    // 5. Cleanup
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    
    //printing the info

    
    

//grab histoigram objets
    MultiDimensionalHistogram *mdh = [_histograms objectAtIndex:_counter];
    
    
    
    //now iterate through ever pixel, knowing whether or not to count the black background in the histograms
    //depending on what i decided
    UInt32 * currentPixel = pixels;
    for (NSUInteger h = 0; h < height; h++) {
    for (NSUInteger w = 0; w < width; w++) {
            UInt32 color = *currentPixel;
            //            NSLog(@"r=%u g=%u b=%u", R(color),G(color),B(color));
            
            //black pixel check
            if((R(color)+G(color)+B(color))<= 250){
                //dont add to histogram
            }
            else{
                [mdh addRed:R(color) green:G(color) blue:B(color)];
            }
            currentPixel++;
        }
    }
    _counter++;
    [self grossColorComparison];
}
//-(void)getStatsAboutImage:(UIImage *)image{
//    // 1.
//    CGImageRef inputCGImage = [image CGImage];
//    NSUInteger width = CGImageGetWidth(inputCGImage);
//    NSUInteger height = CGImageGetHeight(inputCGImage);
//    
//    // 2.
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    
//    UInt32 * pixels;
//    pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
//    
//    // 3.
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    
//    // 4.
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
//    
//    // 5. Cleanup
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//
//    
//    //storing image data
//    int blackPixels = 0;
//    int whitePixels = 0;
//    
//    //this array holds the number of white pixels in each tile (aka section)
//    NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:9];
//    //zero out array
//    for(int i=0;i<9;i++)
//        tiles[i] = @0;
//    
//    //this array holds the number of pixel segmentation (b/w/b/w/) in each tile (aka section)
//    NSMutableArray *segmentationsInTile = [NSMutableArray arrayWithCapacity:9];
//    //zero out array
//    for(int i=0;i<9;i++)
//        segmentationsInTile[i] = @0;
//    
//    
//    
//    NSArray *tileDescriptions = @[@"Top left", @"Top Center", @"Top Right", @"Center Left",@"CENTER", @"Center Right",@"Bottom Left",@"Bottom Center",@"Bottom Right"];
//    int tileSize = ((int)width/3)+1;
//    int column = 0;
//    int row = 0;
//    int index = 0;
//    int totalMass,totalMassX,totalMassY;
//    
//    NSLog(@"Brightness of image:");
//    // 2.
//    UInt32 * currentPixel = pixels;
//    bool pixelWasBlack;
//    for (NSUInteger h = 0; h < height; h++) {
//        //reset bool variable for each row
//        pixelWasBlack = true;
//        row = (int)(h/tileSize);
//        for (NSUInteger w = 0; w < width; w++) {
//            // Print out black/white
//            column = (int)(w/tileSize);
//            index = (row*3)+column;
//            UInt32 color = *currentPixel;
//            printf("%3.0f ", (R(color)+G(color)+B(color))/3.0);
//            //sort into total black or white pixel array
//            if((R(color)+G(color)+B(color))/3.0 == 0){
//                //black
//                blackPixels++;
//                if(!pixelWasBlack) //means previous pixel was white
//                {
//                    int currentValue = [segmentationsInTile[index]intValue];
//                    segmentationsInTile[index] = [NSNumber numberWithInt:++currentValue];
//                }
//
//                //reset segmeentaion bool
//                pixelWasBlack = true;
//            }
//            else{
//                //white
//                whitePixels++;
//                
//                if(pixelWasBlack) //means previous pixel was black
//                {
//                    int currentValue = [segmentationsInTile[index]intValue];
//                    segmentationsInTile[index] = [NSNumber numberWithInt:++currentValue];
//                }
//                
//                //add number of white pixels to relevant tile/index of image
//                int currentValue = [tiles[index]intValue];
//                tiles[index] = [NSNumber numberWithInt:++currentValue];
//                
//                //total mass calculations
//                totalMass += 1;
//                totalMassX += w;
//                totalMassY += h;
//                
//                //reset segmeentaion bool
//                pixelWasBlack = false;
//            }
//            
//            
//            // increment current pixe;
//            currentPixel++;
//            printf("\n");
//        }
//    }
//    
//    //Center of mass calcul
//    int centerMassX,centerMassY;
//    centerMassX = totalMassX/totalMass;
//    centerMassY = totalMassY/totalMass;
//    NSLog(@"Center of Mass x,y = %i,%i",centerMassX,centerMassY);
//    
//    //Print out generic info
//    NSLog(@"black pixels = %i | white pixels = %i ",blackPixels,whitePixels);
//    NSLog(@"ratio of black/white = %d",blackPixels/whitePixels);
//    double percent = (double)(whitePixels/(blackPixels+whitePixels));
//    NSLog(@"%f of white pixels from total pixels = ",percent);
//    
//    //print content of tiles
//    NSLog(@"Number of white tiles in each tile...");
//    int maxTile= 0;
//    for(int i=0;i<tiles.count;i++){
//        if(tiles[i] > tiles[maxTile])
//        maxTile = i;
//        NSLog(@"%@ = %@",tileDescriptions[i],tiles[i]);
//    }
////    NSLog(@"Dominant tile is = %@",tileDescriptions[maxTile]);
//    
//    //print the # of segmentations in each tile
//    NSLog(@"Number of segmentations in dominant tile - %@",segmentationsInTile[maxTile]);
//    
//    int segmentationsInDominantTile = [segmentationsInTile[maxTile]intValue];
//    NSString *gesture;
//    if(segmentationsInDominantTile < MAX_THESHOLD_WHITE_PIXELS_FOR_FIST){
//        gesture = @"FIST";
//    }
//    else if(segmentationsInDominantTile > MIN_THRESHOLD_WHITE_PIXELS_FOR_FIVE){
//        gesture = @"FIVE";
//    }
//    else{
//        gesture = @"Unknown";
//    }
//    
//    NSLog(@"Recognized %@ - %@",gesture,tileDescriptions[maxTile]);
//    
//    if([gesture isEqualToString:@"Unknown"]){
//        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Image gesture unrecognized" message:@"Please snap another picture?" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [av show];
//        return;
//    }
//
//    
//    
//        
//    
//    
//    
//    
//    
//    //set the buttons image
////    [_activeButton setBackgroundImage:_originalImage forState:UIControlStateNormal];
//    if(part1isSet == NO){
//        part1isSet = YES;
//        //set the 1st steps desc label
//        [_part1 setBackgroundImage:_originalImage forState:UIControlStateNormal];
//        [_part1 setTitle:gesture forState:UIControlStateNormal];
//        _descriptionLabel1.text = tileDescriptions[maxTile];
//    }
//    else{
//        //set the 2nds
//        [_part2 setBackgroundImage:_originalImage forState:UIControlStateNormal];
//        [_part2 setTitle:gesture forState:UIControlStateNormal];
//        _descriptionLabel2.text = tileDescriptions[maxTile];
//        
////        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Proceed?" message:@"Are you happy with the password combinations you have entered?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
////        [av show];
//        
//        if(/* DISABLES CODE */ (0)==1){
//            //created password
//            [self performSegueWithIdentifier:@"ToSecret" sender:self];
//        }
//        else{
//            NSString *firstEntry = [NSString stringWithFormat:@"%@ - %@",_part1.titleLabel.text,_descriptionLabel1.text];
//            NSString *secondEntry = [NSString stringWithFormat:@"%@ - %@",_part2.titleLabel.text,_descriptionLabel2.text];
//            _statusLabel.hidden = NO;
//            if([firstEntry isEqualToString:@"FIVE - Center Left"]&&[secondEntry isEqualToString:@"FIST - CENTER"]){
//                //password is GOOD
//                _statusLabel.text = @"CORRECT PW!";
//                _statusLabel.textColor = [UIColor greenColor];
//
////                [self performSelector:@selector(toSecret) withObject:nil afterDelay:10.0f];
//            }
//            else{
//                _statusLabel.text = @"WRONG PW!";
//                _statusLabel.textColor = [UIColor redColor];
//            }
//            
//        }
//    }
//
//
//}

//-(void)binarizeImage{
//     //binarize image
//    UIImage *inputImage = _originalImage;
//    
//     GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
//     //    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
//     
//    
//    GPUImageLuminanceThresholdFilter *stillImageFilter = [[GPUImageLuminanceThresholdFilter alloc]init];
//    
////        GPUImageMonochromeFilter *stillImageFilter = [[GPUImageMonochromeFilter alloc]init];
//    
//     [stillImageSource addTarget:stillImageFilter];
//     [stillImageFilter useNextFrameForImageCapture];
//     
//     
//     [stillImageSource processImage];
//     
//     UIImage *binarizedImage = [stillImageFilter imageFromCurrentFramebuffer];
//     self.imageView.image = binarizedImage;
//     
////     [self getStatsAboutImage:binarizedImage];
//}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
#pragma mark - resizing image
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - IBACTIONs
-(void)print2dArray:(NSMutableArray*)array{
    for (int i=0; i<array.count; i++) {
        NSString *row =@"";
        for (int j=0; j<array.count; j++) {
            row = [row stringByAppendingPathComponent:[NSString stringWithFormat:@"%.2f ",[array[i][j]doubleValue]]];
        }
        NSLog(@"%@",row);
    }
}
#pragma mark - tableview data sorce
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    return _imageNames.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section{
    if(SHOW_CLUSTERS){
    return @"Single Link";
    }
    else
    return [NSString stringWithFormat:@"original | sim | dif - eden,gidi,daniel"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if(SHOW_CLUSTERS == YES){
        NSMutableArray *cluster = _imageNames[indexPath.row];
        ClusterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClusterCell" forIndexPath:indexPath];
        if(!cell)
            cell = [[ClusterCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ClusterCell"];
        else{
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }

            double y = 0.0;
            double w = 30.0;
            double h = 20.0;
            double x = 0.0;
            for(int i=0;i<cluster.count;i++){
                NSString *imgName = [self imageNameFromIndex:[cluster[i]intValue]];
                UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imgName]];
                imageView.frame = CGRectMake(x, y, w, h);
                UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(x, y+h, w, 20)];
                lbl.font = [UIFont systemFontOfSize:12.0f];
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.text = [NSString stringWithFormat:@"%i",[cluster[i]intValue]];
                
                //add to subview
                [cell addSubview:imageView];
                [cell addSubview:lbl];
                
                if(i==9||i==18){
                    y = y + 40;
                    x = 0.0;
                }
                else{
                    x = x + w;
                }
                
            }
        return cell;
        }
    
    else{
    NSMutableArray *images = _imageNames[indexPath.row];
    InfoDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    if(!cell){
        cell = [[InfoDisplayTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InfoCell"];
    }
        cell.rootImage.image = [UIImage imageNamed:[self imageNameFromIndex:[images[0] intValue]]];
        cell.image1.image = [UIImage imageNamed:[self imageNameFromIndex:[images[1] intValue]]];
        cell.image2.image = [UIImage imageNamed:[self imageNameFromIndex:[images[2] intValue]]];
        cell.image3.image = [UIImage imageNamed:[self imageNameFromIndex:[images[3] intValue]]];
        cell.image4.image = [UIImage imageNamed:[self imageNameFromIndex:[images[4] intValue]]];
        cell.image5.image = [UIImage imageNamed:[self imageNameFromIndex:[images[5] intValue]]];
        cell.image6.image = [UIImage imageNamed:[self imageNameFromIndex:[images[6] intValue]]];

        cell.rootLabel.text = [NSString stringWithFormat:@"%i",[images[0] intValue]];
        cell.label1.text = [NSString stringWithFormat:@"%i",[images[1] intValue]];
        cell.label2.text = [NSString stringWithFormat:@"%i",[images[2] intValue]];
        cell.label3.text = [NSString stringWithFormat:@"%i",[images[3] intValue]];
        cell.label4.text = [NSString stringWithFormat:@"%i",[images[4] intValue]];
        cell.label5.text = [NSString stringWithFormat:@"%i",[images[5] intValue]];
        cell.label6.text = [NSString stringWithFormat:@"%i",[images[6] intValue]];
    return cell;
    }
    
}
-(NSString*)imageNameFromIndex:(int)index{
    NSString *imgName;
    if(index<10)
            imgName = [NSString stringWithFormat:@"i0%i.jpg",index];
        else
            imgName = [NSString stringWithFormat:@"i%i.jpg",index];
    return imgName;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(SHOW_CLUSTERS){
        NSMutableArray *clusters = _imageNames[indexPath.row];
        if(clusters.count < 12) return 50;
        else return 100;
    }
    else return 47.0;
}

@end

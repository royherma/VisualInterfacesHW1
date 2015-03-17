//
//  ComparisonTester.m
//  HW1Visual
//
//  Created by Roy Hermann on 3/17/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import "ComparisonTester.h"

@interface ComparisonTester ()

@property NSMutableArray *overallScores;

@end

@implementation ComparisonTester

-(id)initCustom{
    if(self=[super init]){
        //7 by x array
        _imageClusterMatchingResults = [NSMutableArray new];
        _overallScores = [NSMutableArray new];
        return self;
    }
    return nil;
    
    
}

-(double)getScoreFromSystemMatches:(NSMutableArray*)systemMatches andUserMatches:(NSMutableArray*)userMatches{
    double score = 0;
    for(int i=0;i<systemMatches.count;i++){
        NSMutableArray *results = systemMatches[i];
        int userChosenImage = [userMatches[i]intValue];
        bool givenPoints = false;
        for(int j=0;j<results.count;j++){
            if([results[j]intValue] == userChosenImage){
                score = score+1;
            }
            /* added for creativity step */
            //if it isn't one of the three, check and see if its real close to one of the three
            //if so, add partial score
            else{
                MultiDimensionalHistogram *h = _colorHistograms[userChosenImage-1];
                NSString *a = [NSString stringWithFormat:@"%i",[results[j]intValue]];
                double similarity = [[h.comparedHistograms objectForKey:a] doubleValue];
                if(similarity >= 0.85 && !givenPoints){
                    score = score + similarity;
                    givenPoints = YES;
                }
            }
        }
    }
    double finalScore = (double)score/40;
    [_overallScores addObject:[NSNumber numberWithDouble:finalScore]];
    return finalScore;
}
-(double)getScoreForUserChosenClusterMatches:(NSMutableArray*)clusterMatches{
    double score = 0;
    int attempts = 0;
    NSMutableDictionary *relationships = [NSMutableDictionary new];
    for(int i=0;i<clusterMatches.count;i++){
        //grab original cluster
        NSMutableArray *thereCluster = clusterMatches[i];
        int numberOfMatchesInSet = 0;
        //iterate each of the users cluster on my cluster
        for(int j=0;j<_imageClusterMatchingResults.count;j++){
            NSMutableArray *myCluster = _imageClusterMatchingResults[j];
            //check for each number in my cluster, if its in there cluster
            for(int k=0;k<myCluster.count;k++){
                int imageNumberA = [myCluster[k]intValue];
                for(int l=0;l<myCluster.count;l++){
                    int imageNumberB = [myCluster[l]intValue];
                    if(imageNumberA==imageNumberB){
                        if([relationships objectForKey:[NSNumber numberWithInt:imageNumberA]]==nil){
                            //this is where the magic happens
                            //1. increment number of matches in set
                            numberOfMatchesInSet++;
                            //2. higher score for more matches in a set
                            double addToScore = (numberOfMatchesInSet * 2);
                            //3. Make score addition relative to how big the set is..smaller sets = higher points
                            addToScore = addToScore*5/thereCluster.count;
                            score += addToScore;
                            //4. Save entries
                            [relationships setObject:@1 forKey:[NSNumber numberWithInt:imageNumberA]];
                        }
                    }
                        attempts++;
                }
            }
        }
    }
    
    
    return (double)(score)/(attempts);
}
-(double)overallScore{
    double sum = 0;
    for(int i=0;i<_overallScores.count;i++){
        sum+= [_overallScores[i] doubleValue];
    }
    return (sum / _overallScores.count);
}
@end

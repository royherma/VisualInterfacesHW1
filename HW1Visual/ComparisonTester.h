//
//  ComparisonTester.h
//  HW1Visual
//
//  Created by Roy Hermann on 3/17/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiDimensionalHistogram.h"
#import "LaplacianHistogram.h"

@interface ComparisonTester : NSObject

@property NSMutableArray *imageColorMatchingResultsSimilar;
@property NSMutableArray *imageColorMatchingResultsDifferent;
@property NSMutableArray *imageTexturerMatchingResultsSimilar;
@property NSMutableArray *imageTexturerMatchingResultsDifferent;
@property NSMutableArray *imageClusterMatchingResults;

@property NSMutableArray *colorHistograms;
@property NSMutableArray *textureHistograms;

-(double)getScoreFromSystemMatches:(NSMutableArray*)systemMatches andUserMatches:(NSMutableArray*)userMatches;
-(double)getScoreForUserChosenClusterMatches:(NSMutableArray*)clusterMatches;
-(double)overallScore;
-(id)initCustom;
@end

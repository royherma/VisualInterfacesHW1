//
//  MultiDimensionalHistogram.h
//  HW1Visual
//
//  Created by Roy Hermann on 3/11/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiDimensionalHistogram : NSObject

@property NSMutableArray *greenBinValues;
@property NSMutableArray *greenHistograms;
@property NSMutableArray *redAndBlueHistograms;
@property NSMutableArray *mostSimilarHistograms;
@property NSMutableArray *mostDifferentHistograms;
@property NSMutableDictionary *comparedHistograms;
@property int numberOfBlackPixels;
@property int imageIndex;
@property int totalNumberOfPixels;

-(id)initProperties;
-(void)addRed:(float)red green:(float)green blue:(float)blue;

-(NSMutableArray*)sortArrayDescending;
-(NSDictionary*)compareWithHistogram:(MultiDimensionalHistogram*)b;


@end

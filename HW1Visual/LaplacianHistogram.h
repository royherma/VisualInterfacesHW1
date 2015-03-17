//
//  LaplacianHistogram.h
//  HW1Visual
//
//  Created by Roy Hermann on 3/15/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaplacianHistogram : NSObject

@property int imageIndex;
@property NSMutableArray *bins;
@property NSMutableArray *mostSimilarHistograms;
@property NSMutableArray *mostDifferentHistograms;
@property NSMutableDictionary *comparedHistograms;
@property int totalNumberOfPixels;

-(id)initCustom;
-(void)addPixelValueToBin:(int)pixelValue;

//comparison
-(NSDictionary*)compareWithHistogram:(LaplacianHistogram*)b;
-(NSArray*)sortArrayDescending;

@end

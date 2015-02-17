//
//  FaceDetectionViewController.h
//  HW1Visual
//
//  Created by Roy Hermann on 2/17/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface FaceDetectionViewController : UIViewController <GPUImageVideoCameraDelegate>
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImagePicture *sourcePicture;
    GPUImageUIElement *uiElementInput;
    
    GPUImageFilterPipeline *pipeline;
    UIView *faceView;
    UIView *middleView;
    
    CIDetector *faceDetector;
    
    IBOutlet UILabel *tileInfoLabel;
    IBOutlet UILabel *topLeftTile;
    IBOutlet UILabel *topRightTile;
    IBOutlet UILabel *bottomLeftTile;
    IBOutlet UILabel *bottomRightTile;
    __unsafe_unretained UISlider *_filterSettingsSlider;
    BOOL faceThinking;
}

@property(readwrite, unsafe_unretained, nonatomic) IBOutlet UISlider *filterSettingsSlider;
@property(nonatomic,retain) CIDetector*faceDetector;
@property NSMutableArray *tileCountArray;

// Initialization and teardown
- (void)setupFilter;
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

// Filter adjustments
- (void)GPUVCWillOutputFeatures:(NSArray*)featureArray forClap:(CGRect)clap
                 andOrientation:(UIDeviceOrientation)curDeviceOrientation;


@end

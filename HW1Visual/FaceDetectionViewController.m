//
//  FaceDetectionViewController.m
//  HW1Visual
//
//  Created by Roy Hermann on 2/17/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import "FaceDetectionViewController.h"

@interface FaceDetectionViewController ()
@property NSArray *tiles;
@property NSArray *passwordOrder;
@property NSMutableArray *entryOrderArray;
@property int counter;
@end

@implementation FaceDetectionViewController
@synthesize faceDetector;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([GPUImageContext supportsFastTextureUpload])
    {
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        faceThinking = NO;
    }
    
    //init counter
    _counter = 0;
    //add tags for easy comparison afterwards
    topRightTile.tag = 1;
    topLeftTile.tag = 2;
    bottomRightTile.tag = 3;
    bottomLeftTile.tag =4;
    
    //array for "test password"
    _passwordOrder = @[[NSNumber numberWithInt:(int)topRightTile.tag],[NSNumber numberWithInt:(int)topLeftTile.tag],[NSNumber numberWithInt:(int)bottomRightTile.tag],[NSNumber numberWithInt:(int)bottomLeftTile.tag]];
    //for tracking entries
    _entryOrderArray = [NSMutableArray new];
    
    //create array to hold outles
    _tiles = @[topLeftTile,topRightTile,bottomLeftTile,bottomRightTile];
    for(UILabel *l in _tiles){
        l.text = @"";
    }
    //create array for counting time in each tile
    _tileCountArray = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0]];
    
    [self setupFilter];

}
- (void)viewWillDisappear:(BOOL)animated
{
    // Note: I needed to stop camera capture before the view went off the screen in order to prevent a crash from the camera still sending frames
    [videoCamera stopCameraCapture];
    
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setupFilter;
{
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];
    //    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

    
    
    [videoCamera rotateCamera];
    self.title = @"Face Detection";
    self.filterSettingsSlider.hidden = YES;
    
    [self.filterSettingsSlider setValue:1.0];
    [self.filterSettingsSlider setMinimumValue:0.0];
    [self.filterSettingsSlider setMaximumValue:2.0];
    
    filter = [[GPUImageSaturationFilter alloc] init];
    [videoCamera setDelegate:self];
    
    [videoCamera addTarget:filter];
    videoCamera.runBenchmark = YES;
    GPUImageView *filterView = (GPUImageView *)self.view;
    
    [filter addTarget:filterView];
    
    
    [videoCamera startCameraCapture];
}
#pragma mark - Face Detection Delegate Callback
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (!faceThinking) {
        CFAllocatorRef allocator = CFAllocatorGetDefault();
        CMSampleBufferRef sbufCopyOut;
        CMSampleBufferCreateCopy(allocator,sampleBuffer,&sbufCopyOut);
        [self performSelectorInBackground:@selector(grepFacesForSampleBuffer:) withObject:CFBridgingRelease(sbufCopyOut)];
    }
}

- (void)grepFacesForSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    faceThinking = TRUE;
//    NSLog(@"Faces thinking");
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    if (attachments)
        CFRelease(attachments);
    NSDictionary *imageOptions = nil;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    int exifOrientation;
    
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    BOOL isUsingFrontFacingCamera = FALSE;
    AVCaptureDevicePosition currentCameraPosition = [videoCamera cameraPosition];
    
    if (currentCameraPosition != AVCaptureDevicePositionBack)
    {
        isUsingFrontFacingCamera = TRUE;
    }
    
    switch (curDeviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    
    imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    
//    NSLog(@"Face Detector %@", [self.faceDetector description]);
//    NSLog(@"converted Image %@", [convertedImage description]);
    NSArray *features = [self.faceDetector featuresInImage:convertedImage options:imageOptions];
    
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);

    
    [self GPUVCWillOutputFeatures:features forClap:clap andOrientation:curDeviceOrientation];
    faceThinking = FALSE;
    
}

- (void)GPUVCWillOutputFeatures:(NSArray*)featureArray forClap:(CGRect)clap
                 andOrientation:(UIDeviceOrientation)curDeviceOrientation
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"Did receive array");
        
        CGRect previewBox = self.view.frame;
        
        if (featureArray == nil && faceView) {
            [faceView removeFromSuperview];
            faceView = nil;
        }
        
        
        for ( CIFaceFeature *faceFeature in featureArray) {
            
            // find the correct position for the square layer within the previewLayer
            // the feature box originates in the bottom left of the video frame.
            // (Bottom right if mirroring is turned on)
//            NSLog(@"%@", NSStringFromCGRfaceViewect([faceFeature bounds]));
            
            //Update face bounds for iOS Coordinate System
            CGRect faceRect = [faceFeature bounds];
            
            // flip preview width and height
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
            CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;
            
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            
            if (faceView) {
                [faceView removeFromSuperview];
                faceView =  nil;
            }
            if(middleView){
                [middleView removeFromSuperview];
                middleView = nil;
            }
            
            // create a UIView using the bounds of the face
            faceView = [[UIView alloc] initWithFrame:faceRect];
            
            [self.view addSubview:faceView];
            
            // add a border around the newly created UIView
            faceView.layer.borderWidth = 1;
            faceView.layer.borderColor = [[UIColor redColor] CGColor];
            
            NSLog(@"%@",NSStringFromCGPoint(faceRect.origin));
            
            // add the new view to create a box around the face
            
            //create my custom middle point of face
            middleView = [[UIView alloc] initWithFrame:CGRectMake(faceView.center.x, faceView.center.y, 5, 5)]
            ;
            middleView.layer.cornerRadius = middleView.frame.size.width/2;
            middleView.backgroundColor = [UIColor redColor];
            
            [self.view addSubview:middleView];
            
            //find tile that face is IN according to center point
            int x = (int)middleView.center.x;
            int y = (int)middleView.center.y;
            if(x<100){
                //must be left
                if(y>160 && y<260)
                {
                    //top
                    if(topLeftTile.text.length ==0){
                        topLeftTile.text = [NSString stringWithFormat:@"%i",++_counter];
                     [_entryOrderArray addObject:[NSNumber numberWithInt:(int)topLeftTile.tag]];
                    }
                }
                else if(y>360 && y<460){
                    //bottom
                    if(bottomLeftTile.text.length ==0){
                            bottomLeftTile.text = [NSString stringWithFormat:@"%i",++_counter];
                            [_entryOrderArray addObject:[NSNumber numberWithInt:(int)bottomLeftTile.tag]];
                    }
                }
            }
            else if(x > 220){
                //must be right
                if(y>160 && y<260)
                {
                    //top
                    if(topRightTile.text.length == 0){
                        topRightTile.text = [NSString stringWithFormat:@"%i",++_counter];
                        [_entryOrderArray addObject:[NSNumber numberWithInt:(int)topRightTile.tag]];
                    }
                }
                else if(y>360 && y<460){
                    //bottom
                    if(bottomRightTile.text.length ==0){
                        bottomRightTile.text = [NSString stringWithFormat:@"%i",++_counter];
                        [_entryOrderArray addObject:[NSNumber numberWithInt:(int)bottomRightTile.tag]];
                    }
                }

            }
        }
        //if counter reached 3(..but means all 4) - all corner tiles have been detected
        if(_counter == 4)
            [self checkIfPasswordIsCorrect];
    });
    
}
-(void)checkIfPasswordIsCorrect{
    _counter++; // stop incrementing;
    NSString *labelValue = @"PASSWORD IS GOOD!";
    for(int i=0;i<_passwordOrder.count;i++){
        int pwEntry = [_passwordOrder[i]intValue];
        int newEntry = [_entryOrderArray[i] intValue];        
        if(pwEntry != newEntry)
            labelValue = @"PASSWORD IS BAD!!!";
    }
    tileInfoLabel.text = labelValue;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

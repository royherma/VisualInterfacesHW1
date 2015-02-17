//
//  ViewController.m
//  HW1Visual
//
//  Created by Roy Hermann on 2/15/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>

@interface ViewController ()

@property UIImage *originalImage;
@property UIButton *activeButton;
@property NSString *savedPasswordCombination1;
@property NSString *savedPasswordCombination2;


@end

BOOL createPassword,part1isSet;

#define MIN_THRESHOLD_WHITE_PIXELS_FOR_FIVE 150
#define MAX_THESHOLD_WHITE_PIXELS_FOR_FIST 125


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //for testing against preset password
    _savedPasswordCombination1 = @"FIVE – Center Left";
    _savedPasswordCombination2 = @"FIST – CENTER";
    _part1.tag = 1;
    _part1.tag = 2;
    [_part1 addTarget:self action:@selector(ivTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_part2 addTarget:self action:@selector(ivTapped:) forControlEvents:UIControlEventTouchUpInside];

}
-(void)getStatsAboutImage:(UIImage *)image{
    // 1.
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
    
    // 1.
    #define Mask8(x) ( (x) & 0xFF )
    #define R(x) ( Mask8(x) )
    #define G(x) ( Mask8(x >> 8 ) )
    #define B(x) ( Mask8(x >> 16) )
    
    //storing image data
    int blackPixels = 0;
    int whitePixels = 0;
    
    //this array holds the number of white pixels in each tile (aka section)
    NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:9];
    //zero out array
    for(int i=0;i<9;i++)
        tiles[i] = @0;
    
    //this array holds the number of pixel segmentation (b/w/b/w/) in each tile (aka section)
    NSMutableArray *segmentationsInTile = [NSMutableArray arrayWithCapacity:9];
    //zero out array
    for(int i=0;i<9;i++)
        segmentationsInTile[i] = @0;
    
    
    
    NSArray *tileDescriptions = @[@"Top left", @"Top Center", @"Top Right", @"Center Left",@"CENTER", @"Center Right",@"Bottom Left",@"Bottom Center",@"Bottom Right"];
    int tileSize = ((int)width/3)+1;
    int column = 0;
    int row = 0;
    int index = 0;
    int totalMass,totalMassX,totalMassY;
    
    NSLog(@"Brightness of image:");
    // 2.
    UInt32 * currentPixel = pixels;
    bool pixelWasBlack;
    for (NSUInteger h = 0; h < height; h++) {
        //reset bool variable for each row
        pixelWasBlack = true;
        row = (int)(h/tileSize);
        for (NSUInteger w = 0; w < width; w++) {
            // Print out black/white
            column = (int)(w/tileSize);
            index = (row*3)+column;
            UInt32 color = *currentPixel;
            printf("%3.0f ", (R(color)+G(color)+B(color))/3.0);
            //sort into total black or white pixel array
            if((R(color)+G(color)+B(color))/3.0 == 0){
                //black
                blackPixels++;
                if(!pixelWasBlack) //means previous pixel was white
                {
                    int currentValue = [segmentationsInTile[index]intValue];
                    segmentationsInTile[index] = [NSNumber numberWithInt:++currentValue];
                }

                //reset segmeentaion bool
                pixelWasBlack = true;
            }
            else{
                //white
                whitePixels++;
                
                if(pixelWasBlack) //means previous pixel was black
                {
                    int currentValue = [segmentationsInTile[index]intValue];
                    segmentationsInTile[index] = [NSNumber numberWithInt:++currentValue];
                }
                
                //add number of white pixels to relevant tile/index of image
                int currentValue = [tiles[index]intValue];
                tiles[index] = [NSNumber numberWithInt:++currentValue];
                
                //total mass calculations
                totalMass += 1;
                totalMassX += w;
                totalMassY += h;
                
                //reset segmeentaion bool
                pixelWasBlack = false;
            }
            
            
            // increment current pixe;
            currentPixel++;
            printf("\n");
        }
    }
    
    //Center of mass calcul
    int centerMassX,centerMassY;
    centerMassX = totalMassX/totalMass;
    centerMassY = totalMassY/totalMass;
    NSLog(@"Center of Mass x,y = %i,%i",centerMassX,centerMassY);
    
    //Print out generic info
    NSLog(@"black pixels = %i | white pixels = %i ",blackPixels,whitePixels);
    NSLog(@"ratio of black/white = %d",blackPixels/whitePixels);
    double percent = (double)(whitePixels/(blackPixels+whitePixels));
    NSLog(@"%f of white pixels from total pixels = ",percent);
    
    //print content of tiles
    NSLog(@"Number of white tiles in each tile...");
    int maxTile= 0;
    for(int i=0;i<tiles.count;i++){
        if(tiles[i] > tiles[maxTile])
        maxTile = i;
        NSLog(@"%@ = %@",tileDescriptions[i],tiles[i]);
    }
//    NSLog(@"Dominant tile is = %@",tileDescriptions[maxTile]);
    
    //print the # of segmentations in each tile
    NSLog(@"Number of segmentations in dominant tile - %@",segmentationsInTile[maxTile]);
    
    int segmentationsInDominantTile = [segmentationsInTile[maxTile]intValue];
    NSString *gesture;
    if(segmentationsInDominantTile < MAX_THESHOLD_WHITE_PIXELS_FOR_FIST){
        gesture = @"FIST";
    }
    else if(segmentationsInDominantTile > MIN_THRESHOLD_WHITE_PIXELS_FOR_FIVE){
        gesture = @"FIVE";
    }
    else{
        gesture = @"Unknown";
    }
    
    NSLog(@"Recognized %@ - %@",gesture,tileDescriptions[maxTile]);
    
    if([gesture isEqualToString:@"Unknown"]){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Image gesture unrecognized" message:@"Please snap another picture?" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [av show];
        return;
    }

    
    
        
    
    
    
    
    
    //set the buttons image
//    [_activeButton setBackgroundImage:_originalImage forState:UIControlStateNormal];
    if(part1isSet == NO){
        part1isSet = YES;
        //set the 1st steps desc label
        [_part1 setBackgroundImage:_originalImage forState:UIControlStateNormal];
        [_part1 setTitle:gesture forState:UIControlStateNormal];
        _descriptionLabel1.text = tileDescriptions[maxTile];
    }
    else{
        //set the 2nds
        [_part2 setBackgroundImage:_originalImage forState:UIControlStateNormal];
        [_part2 setTitle:gesture forState:UIControlStateNormal];
        _descriptionLabel2.text = tileDescriptions[maxTile];
        
//        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Proceed?" message:@"Are you happy with the password combinations you have entered?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
//        [av show];
        
        if(/* DISABLES CODE */ (0)==1){
            //created password
            [self performSegueWithIdentifier:@"ToSecret" sender:self];
        }
        else{
            NSString *firstEntry = [NSString stringWithFormat:@"%@ - %@",_part1.titleLabel.text,_descriptionLabel1.text];
            NSString *secondEntry = [NSString stringWithFormat:@"%@ - %@",_part2.titleLabel.text,_descriptionLabel2.text];
            _statusLabel.hidden = NO;
            if([firstEntry isEqualToString:@"FIVE - Center Left"]&&[secondEntry isEqualToString:@"FIST - CENTER"]){
                //password is GOOD
                _statusLabel.text = @"CORRECT PW!";
                _statusLabel.textColor = [UIColor greenColor];

//                [self performSelector:@selector(toSecret) withObject:nil afterDelay:10.0f];
            }
            else{
                _statusLabel.text = @"WRONG PW!";
                _statusLabel.textColor = [UIColor redColor];
            }
            
        }
    }


}
-(void)entryPressed:(id)sender{
    UIButton *btn = sender;
    if([btn.titleLabel.text isEqualToString:@"Part 1"] || [btn.titleLabel.text isEqualToString:@"Part 2"]){
    _activeButton = sender;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.showsCameraControls = YES;
    [self presentViewController:picker animated:YES completion:NULL];
    }
    
}

#pragma picker deleg
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
//    UIImage *chosenImage = [UIImage imageNamed:@"five_bottom_left_WHITEBG.png"];
    UIImage *scaledDownImage = [ViewController imageWithImage:chosenImage scaledToSize:_imageView.frame.size];
    
    //for referencing later
    _originalImage = scaledDownImage;

    
//    self.imageView.image = scaledDownImage;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self binarizeImage];
    }];
     
}
-(void)binarizeImage{
     //binarize image
    UIImage *inputImage = _originalImage;
    
     GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
     //    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
     
    
    GPUImageLuminanceThresholdFilter *stillImageFilter = [[GPUImageLuminanceThresholdFilter alloc]init];
    
//        GPUImageMonochromeFilter *stillImageFilter = [[GPUImageMonochromeFilter alloc]init];
    
     [stillImageSource addTarget:stillImageFilter];
     [stillImageFilter useNextFrameForImageCapture];
     
     
     [stillImageSource processImage];
     
     UIImage *binarizedImage = [stillImageFilter imageFromCurrentFramebuffer];
     self.imageView.image = binarizedImage;
     
     [self getStatsAboutImage:binarizedImage];
}
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
-(IBAction)clearEntries:(id)sender{
    _statusLabel.hidden = YES;
    [_part1 setBackgroundImage:nil forState:UIControlStateNormal];
    [_part1 setTitle:@"Part 1" forState:UIControlStateNormal];
    //set the 2nds
    [_part2 setBackgroundImage:nil forState:UIControlStateNormal];
    [_part2 setTitle:@"Part 2" forState:UIControlStateNormal];
    _descriptionLabel2.text = @"";
    _descriptionLabel1.text = @"";
    //clear
    part1isSet = NO;

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"ToSecret" sender:self];
    }
}
-(void)toSecret{
    [self performSegueWithIdentifier:@"ToSecret" sender:self];
}
-(void)ivTapped:(UIButton*)sender{
    if(sender == _part1){
        part1isSet = false;
        [_part1 setBackgroundImage:nil forState:UIControlStateNormal];
        [_part1 setTitle:@"Part 1" forState:UIControlStateNormal];
        _descriptionLabel1.text = @"";
    }
    else{
        [_part2 setBackgroundImage:nil forState:UIControlStateNormal];
        [_part2 setTitle:@"Part 2" forState:UIControlStateNormal];
        _descriptionLabel2.text = @"";
        _statusLabel.hidden = YES;
    }
}
@end

//
//  ViewController.h
//  HW1Visual
//
//  Created by Roy Hermann on 2/15/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIAlertViewDelegate>

@property IBOutlet UIImageView *imageView;

@property IBOutlet UIButton *part1;
@property IBOutlet UIButton *part2;

@property IBOutlet UILabel *descriptionLabel1;
@property IBOutlet UILabel *descriptionLabel2;

@property IBOutlet UILabel *statusLabel;

-(IBAction)clearEntries:(id)sender;
-(IBAction)entryPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end


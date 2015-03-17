//
//  ViewController.h
//  HW1Visual
//
//  Created by Roy Hermann on 2/15/15.
//  Copyright (c) 2015 Roy Hermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property IBOutlet UITableView *tableView;
@property IBOutlet UIImageView *imageView;

@end


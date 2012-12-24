//
//  BackGroundViewController.h
//  RocketNews
//
//  Created by Travis Hoover on 12/20/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupportedSitesObject.h"

@interface BackGroundViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) UITableView *backGroundTableView;
@property (nonatomic, retain) SupportedSitesObject *supportedSitesObject;

@end

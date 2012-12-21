//
//  MainViewController.h
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryWebViewController.h"
#import "RedditAPIObject.h"

@interface StoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) StoryWebViewController *webView;
@property (nonatomic, retain) RedditAPIObject *reddit;


@property (nonatomic, retain) UITableView *storyTableView;

@end

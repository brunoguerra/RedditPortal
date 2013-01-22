//
//  MainViewController.h
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryWebViewController.h"
#import <SSPullToRefresh.h>
#import "AppDelegate.h"
#import "Reddit.h"

@interface StoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SSPullToRefreshViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) StoryWebViewController *webView;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@property (nonatomic, retain) UITableView *storyTableView;
@property (nonatomic, retain) Reddit *reddit;

- (void)refresh;

@end

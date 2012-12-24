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
#import <SSPullToRefresh.h>
#import "AppDelegate.h"

@interface StoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SSPullToRefreshViewDelegate>

@property (nonatomic, retain) StoryWebViewController *webView;

@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

@property (nonatomic, retain) UITableView *storyTableView;

- (void)refresh;
- (void)stopRefreshing;

@end

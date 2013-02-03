//
//  MainViewController.h
//  Reddit Portal
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import <SSPullToRefresh.h>

#import "Reddit.h"
#import "StoryWebViewController.h"


@interface StoryViewController : UIViewController <UITableViewDelegate,
                                                 UITableViewDataSource,
                                           SSPullToRefreshViewDelegate,
                                                 MBProgressHUDDelegate,
                                                 UIActionSheetDelegate>

@property (nonatomic, retain) Reddit *reddit;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) UITableView *storyTableView;
@property (nonatomic, retain) StoryWebViewController *webView;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

- (void) loadMoreStories;
- (void) loadMoreStoriesIfChange;

@end

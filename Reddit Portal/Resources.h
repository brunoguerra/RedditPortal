//
//  Resources.h
//  Reddit Portal
//
//  Created by Travis Hoover on 1/24/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD.h>
#import <SSPullToRefresh.h>

@interface Resources : NSObject

+ (UIWebView *)createWebViewForView:(UIView *)view ForCaller:(id)caller;
+ (MBProgressHUD *)createHUDForView:(UIView *)view ForCaller:(id)caller;
+ (UIActionSheet *)createActionSheetWithButtons:(NSArray *)buttons WithTag:(NSInteger)tag ForCaller:(id)caller;
+ (SSPullToRefreshView *)createPullToRefreshForTable:(UITableView *)table withDelegate:(id)del;

@end

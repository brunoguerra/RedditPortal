//
//  Resources.m
//  Reddit Portal
//
//  Created by Travis Hoover on 1/24/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import "Resources.h"
#import <MBProgressHUD.h>
#import <SSPullToRefresh.h>

@implementation Resources

+ (UIWebView *)createWebViewForView:(UIView *)view ForCaller:(id)caller
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:view.frame];
    webView.backgroundColor = [UIColor whiteColor];
    webView.scalesPageToFit = YES;
    webView.contentMode = UIViewContentModeScaleAspectFit;
    webView.delegate = caller;
    
    [view addSubview:webView];
    
    return webView;
}

+ (MBProgressHUD *)createHUDForView:(UIView *)view ForCaller:(id)caller
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.delegate = caller;
    HUD.labelText = @"Loading";
    
    [view addSubview: HUD];
    
    return HUD;
}

+ (UIActionSheet *)createActionSheetWithButtons:(NSArray *)buttons WithTag:(NSInteger)tag ForCaller:(id)caller
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:caller
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    for (int i = 0; i < [buttons count]; i++)
    {
        [sheet addButtonWithTitle:[buttons objectAtIndex:i]];
    }
    
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = buttons.count;
    
    sheet.tag = tag;
    return sheet;
}

+ (SSPullToRefreshView *)createPullToRefreshForTable:(UITableView *)table withDelegate:(id)del
{
    SSPullToRefreshView *pullRefresh = [[SSPullToRefreshView alloc] initWithScrollView:table
                                                                              delegate:del];
    return pullRefresh;
}
@end

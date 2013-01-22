//
//  StoryWebViewController.h
//  RocketNews
//
//  Created by Travis Hoover on 12/19/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>

@interface StoryWebViewController : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate, UIActionSheetDelegate>

@property (nonatomic, copy) NSString *storyURL;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) NSDictionary *redditStory;

- (void)loadNewStory;

@end

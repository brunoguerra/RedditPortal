//
//  CommentsViewController.h
//  Reddit Portal
//
//  Created by Travis Hoover on 1/22/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) UIWebView *commentsWebView;

+ (CommentsViewController *) sharedClass;
- (void) loadCommentsForStory:(NSDictionary *)story;
- (void) closeCommentsView;

@end

//
//  AppDelegate.h
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Reddit.h"
#import "StoryViewController.h"
#import "SWRevealViewController.h"
#import "BackGroundViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SWRevealViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UINavigationController *storyNavigationController;
@property (nonatomic, retain) UINavigationController *backGroundNavigationController;
@property (nonatomic, retain) BackGroundViewController *backGroundViewController;
@property (nonatomic, retain) StoryViewController *storyViewController;
@property (nonatomic, retain) Reddit *reddit;

@end

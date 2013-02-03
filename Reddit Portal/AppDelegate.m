//
//  AppDelegate.m
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "Reddit.h"
#import "AppDelegate.h"
#import "StoryViewController.h"
#import "SWRevealViewController.h"
#import "BackGroundViewController.h"

#define BACKGROUND_NAV_WIDTH 230
#define BACKGROUND_NAV_HEIGHT_OFFSET 20

@implementation AppDelegate

@synthesize reddit = _reddit;
@synthesize storyViewController = _storyViewController;
@synthesize backGroundViewController = _backGroundViewController;
@synthesize storyNavigationController = _storyNavigationController;
@synthesize backGroundNavigationController = _backGroundNavigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
    
    
    _reddit = [Reddit sharedClass];
    _storyViewController = [[StoryViewController alloc] init];
    _backGroundViewController = [[BackGroundViewController alloc] init];
    _storyNavigationController = [[UINavigationController alloc] initWithRootViewController:_storyViewController];
    _backGroundNavigationController = [[UINavigationController alloc] initWithRootViewController:_backGroundViewController];
    
    // Custom backgrounds for the navigation bars
    [_storyNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"navigationBar.png"]
                                                   forBarMetrics:UIBarMetricsDefault];
    
    [_backGroundNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"backgroundNavigationBar.png"]
                                                        forBarMetrics:UIBarMetricsDefault];
    
    #pragma mark FIXME: Determine if this can be moved or changed so it works automagically.
    _backGroundNavigationController.view.frame = CGRectMake([[UIScreen mainScreen] bounds].origin.x,
                                                            BACKGROUND_NAV_HEIGHT_OFFSET,
                                                            BACKGROUND_NAV_WIDTH,
                                                            [[UIScreen mainScreen] bounds].size.height);
    
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc]
                                        initWithTarget:[StoryWebViewController sharedClass] action:@selector(navigationBarDoubleTap:)];
    tapRecon.numberOfTapsRequired = 2;
    [_storyNavigationController.navigationBar addGestureRecognizer:tapRecon];
    
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:_backGroundNavigationController
                                                                                      frontViewController:_storyNavigationController];
    revealController.delegate = self;
    
    self.window.rootViewController = revealController;
    [self.window addSubview:_backGroundNavigationController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)revealController:(SWRevealViewController *)revealController willHideRearViewController:(UIViewController *)viewController
{
    // If we are revealing the front view then we might have changed subreddits and if so then we must load the new data.
    
    [_storyViewController loadMoreStoriesIfChange];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

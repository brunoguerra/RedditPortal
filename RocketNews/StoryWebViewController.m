//
//  StoryWebViewController.m
//  RocketNews
//
//  Created by Travis Hoover on 12/19/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "StoryWebViewController.h"
#import <MBProgressHUD.h>
#import "BarButtonItemObject.h"

@interface StoryWebViewController ()

@end

@implementation StoryWebViewController

@synthesize storyURL = _storyURL, webView = _webView, HUD = _HUD;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view = contentView;
    
	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
	webFrame.origin.y = 0.0f;
	_webView = [[UIWebView alloc] initWithFrame:webFrame];
	_webView.backgroundColor = [UIColor whiteColor];
	_webView.scalesPageToFit = YES;
	_webView.delegate = self;
	[self.view addSubview: _webView];
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
    _HUD.delegate = self;
	_HUD.labelText = @"Loading";
    
    [_HUD show:YES];
    
    UIBarButtonItem *backBarButton = [BarButtonItemObject createButtonItemForTarget:self.navigationController
                                                                         withAction:@selector(popViewControllerAnimated:)
                                                                          withImage:@"backArrow.png"
                                                                         withOffset:0];
    
    UIBarButtonItem *actionBarButton = [BarButtonItemObject createButtonItemForTarget:self.navigationController
                                                                           withAction:@selector(popViewControllerAnimated:)
                                                                            withImage:@"action.png"
                                                                           withOffset:10];
    
    UIBarButtonItem *bookmarkBarButton = [BarButtonItemObject createButtonItemForTarget:self.navigationController
                                                                             withAction:@selector(popViewControllerAnimated:)
                                                                              withImage:@"bookmark.png"
                                                                             withOffset:50];
    
    UIBarButtonItem *commentBarButton = [BarButtonItemObject createButtonItemForTarget:self.navigationController
                                                                         withAction:@selector(popViewControllerAnimated:)
                                                                          withImage:@"comments.png"
                                                                         withOffset:50];
    
    UIBarButtonItem *flagBarButton = [BarButtonItemObject createButtonItemForTarget:self.navigationController
                                                                         withAction:@selector(popViewControllerAnimated:)
                                                                          withImage:@"flag.png"
                                                                         withOffset:50];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:actionBarButton, bookmarkBarButton, commentBarButton, flagBarButton, nil];

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_storyURL]]];
}

- (void) loadNewStory
{
    // TODO: fade out effect.
    
    [_HUD show:YES];
    NSLog(@"Loading story: %@", _storyURL);
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_storyURL]]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_HUD hide:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error Loading: %@", _storyURL );
    NSLog(@"%@", error);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

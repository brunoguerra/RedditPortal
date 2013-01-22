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
#import "UILabel+NavigationTitle.h"

@interface StoryWebViewController ()

@end

@implementation StoryWebViewController

@synthesize storyURL = _storyURL;
@synthesize webView = _webView;
@synthesize HUD = _HUD;
@synthesize redditStory = _redditStory;

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
    _webView.contentMode = UIViewContentModeScaleAspectFit;
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
                                                                           withAction:@selector(showActionSheet)
                                                                            withImage:@"action.png"
                                                                           withOffset:10];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:actionBarButton, nil];

   [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_storyURL]]];
}

- (void) showActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"via Email", @"via SMS", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *buttons = nil;
    
    if( buttonIndex == 1 ) // New
    {
        buttons = [NSArray arrayWithObjects:@"New", @"Rising", nil];
    }
    else if ( buttonIndex == 2 || buttonIndex == 3 ) // Controversial or Top
    {
        buttons = [NSArray arrayWithObjects:@"This Hour", @"This Week", @"This Month", @"This Year", @"All Time", nil];
    }
}

- (void) loadNewStory
{
    // TODO: fade out effect.
    
    NSURLRequest *request = nil;
    
    UILabel *navTitle = [[UILabel alloc] initWithTitle:[_redditStory objectForKey:@"domain"] withColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = navTitle;
    
    if ( [[_redditStory objectForKey:@"domain"] isEqualToString:@"self.IAmA"] )
    {
        NSLog(@"%@", _redditStory);
        
        NSString *path = [NSString stringWithFormat:@"%@?id=%@&title=%@&author=%@&created=%@&domain=%@&base=%@&sort=%@",
                          [[NSBundle mainBundle] pathForResource:@"Comments" ofType:@"html"],
                          [[_redditStory objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [[_redditStory objectForKey:@"title"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [[_redditStory objectForKey:@"author"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [@"1358902804" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [[_redditStory objectForKey:@"domain"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [@"http://www.reddit.com" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          @"top"
                          ];
        
        
        
        NSURL *url = [[NSURL alloc] initWithScheme:@"file" host:@"localhost" path:path];
        request = [NSURLRequest requestWithURL:url];
    }
    else
    {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[_redditStory objectForKey:@"url"]]];
    }

    [_HUD show:YES];
    NSLog(@"Loading story: %@", request);
    [_webView loadRequest:request];
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

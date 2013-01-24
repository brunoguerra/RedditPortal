//
//  CommentsViewController.m
//  Reddit Portal
//
//  Created by Travis Hoover on 1/22/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import "CommentsViewController.h"
#import "BarButtonItemObject.h"
#import "NavigationTitleView.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController

@synthesize commentsWebView = _commentsWebView;

+ (CommentsViewController *) sharedClass
{
    // Creates a singleton of this class.
    
    static CommentsViewController *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[CommentsViewController alloc] init];
    });
    return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
        webFrame.origin.y = 0.0f;
        _commentsWebView = [[UIWebView alloc] initWithFrame:webFrame];
        _commentsWebView.backgroundColor = [UIColor whiteColor];
        _commentsWebView.scalesPageToFit = YES;
        _commentsWebView.contentMode = UIViewContentModeScaleAspectFit;
        _commentsWebView.delegate = self;
        [self.view addSubview: _commentsWebView];
        
        UIBarButtonItem *slideButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                           withAction:@selector(closeCommentsView)
                                                                            withImage:@"cancel"
                                                                           withOffset:10];
        self.navigationItem.leftBarButtonItem = slideButton;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) loadCommentsForStory:(NSDictionary *)story
{
    self.navigationItem.titleView = [NavigationTitleView createTitleWithSubReddit:@"Comments:"
                                                                    andSortOption:[NSString stringWithFormat:@"%@",[story objectForKey:@"num_comments"]]];
    
    // Fetches the comments for a given story and sends them to the Comment.html file to be displayed.
    
    NSString *path = [NSString stringWithFormat:@"%@?id=%@&title=%@&author=%@&created=%@&domain=%@&base=%@&sort=%@",
                      [[NSBundle mainBundle] pathForResource:@"Comments" ofType:@"html"],
                      [[story objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                      [[story objectForKey:@"title"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                      [[story objectForKey:@"author"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                      [[NSString stringWithFormat:@"%@",[story objectForKey:@"created"]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                      [[story objectForKey:@"domain"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                      [@"http://www.reddit.com" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                      @"top"];
    
    NSURL *url = [[NSURL alloc] initWithScheme:@"file" host:@"localhost" path:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_commentsWebView loadRequest:request];
}

- (void) closeCommentsView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

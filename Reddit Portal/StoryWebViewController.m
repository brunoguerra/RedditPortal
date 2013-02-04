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
#import "CommentsViewController.h"
#import <MessageUI/MessageUI.h>
#import "YRDropdownView.h"
#import <BlockActionSheet.h>
#import "StoryViewController.h"

#define VIEW_COMMENTS_INDEX 0
#define VIEW_SHARE_INDEX 1
#define PRIMARY_ACTION_SHEET 1
#define SHARING_ACTION_SHEET 2
#define SHARE_VIA_EMAIL 0
#define SHARE_VIA_SMS 1

#define VIEW_COMMENTS_TITLE @"View Comments"
#define SHARE_TITLE @"Share Story"


@interface StoryWebViewController ()

@end

@implementation StoryWebViewController

@synthesize HUD = _HUD;
@synthesize webView = _webView;
@synthesize storyURL = _storyURL;
@synthesize redditStory = _redditStory;
@synthesize isOnStoryWebController = _isOnStoryWebController;

+ (StoryWebViewController *) sharedClass
{
    static StoryWebViewController *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[StoryWebViewController alloc] init];
    });
    return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
        _webView = [Resources createWebViewForView:self.view ForCaller:self];
        _HUD = [Resources createHUDForView:self.view ForCaller:self];
        [_HUD show:YES];
        
        UIBarButtonItem *backBarButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                             withAction:@selector(goBackToStories)
                                                                              withImage:@"backArrow.png"
                                                                             withOffset:10];
        
        UIBarButtonItem *actionBarButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                               withAction:@selector(showActionSheet)
                                                                                withImage:@"action.png"
                                                                               withOffset:10];
        
        
        self.navigationItem.leftBarButtonItem = backBarButton;
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:actionBarButton, nil];
     
        _isOnStoryWebController = false;
    }
    
    return self;
}


- (void)navigationBarDoubleTap:(UIGestureRecognizer*)recognizer
{
    // On double tap we show the more info alert but only when viewing the story.
    
    if( _isOnStoryWebController )
    {
        [YRDropdownView showDropdownInView:self.view
                                     title:[_redditStory objectForKey:@"title"]
                                    detail:[NSString stringWithFormat:@"%@    comments: %@",
                                                      [_redditStory objectForKey:@"author"],
                                                [_redditStory objectForKey:@"num_comments"]]];
    }
}

- (void)goBackToStories
{
    [self.navigationController popViewControllerAnimated:YES];
    [YRDropdownView hideDropdownInView:self.view];
    _isOnStoryWebController = false;
}

- (void) showActionSheet
{
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:nil];
    [sheet addButtonWithTitle:@"View Comments" block:^{
        
        [self showCommentsView];
    }];
    [sheet addButtonWithTitle:@"Share Story" block:^{
        [self shareStory];
    }];
    [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
    [sheet showInView:self.view];
    
    
}

- (void)shareStory
{
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:nil];
    [sheet addButtonWithTitle:@"Via Email" block:^{
        
        // Sharing via Email
        if( [MFMailComposeViewController canSendMail] )
        {
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;
            
            [mailCont setSubject:@"Check out this story on Reddit"];
            [mailCont setToRecipients:[NSArray arrayWithObject:@""]];
            [mailCont setMessageBody:[_redditStory objectForKey:@"url"] isHTML:NO];
            
            [self presentViewController:mailCont animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Account"
                                                            message:@"You must have an email account added to your settings for emails to work."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
    [sheet addButtonWithTitle:@"Via SMS" block:^{
        
        if( [MFMessageComposeViewController canSendText] )
        {
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            
            [messageController setBody:[_redditStory objectForKey:@"url"]];
            [self presentViewController:messageController animated:YES completion:nil];
        }
    }];
    [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
    [sheet showInView:self.view];
}



// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) loadNewStory
{
    _isOnStoryWebController = true;
    [_HUD show:YES];
    

    NSURLRequest *request = nil;
    
    UILabel *navTitle = [[UILabel alloc] initWithTitle:[NSString stringWithFormat:@"%@", [_redditStory objectForKey:@"domain"]]
                                             withColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = navTitle;
    
    if ( [[_redditStory objectForKey:@"domain"] isEqualToString:@"reddit.com"] ||
        [[_redditStory objectForKey:@"domain"] rangeOfString:@"self."].location != NSNotFound)
    {
        NSString *path = [NSString stringWithFormat:@"%@?id=%@&title=%@&author=%@&created=%@&domain=%@&base=%@&sort=%@",
                          [[NSBundle mainBundle] pathForResource:@"Comments" ofType:@"html"],
                          [[_redditStory objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [[_redditStory objectForKey:@"title"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [[_redditStory objectForKey:@"author"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [[NSString stringWithFormat:@"%@",
                            [_redditStory objectForKey:@"created"]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [[_redditStory objectForKey:@"domain"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          [@"http://www.reddit.com" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                          @"top"];
        
        NSURL *url = [[NSURL alloc] initWithScheme:@"file" host:@"localhost" path:path];
        request = [NSURLRequest requestWithURL:url];
    }
    else
    {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:[_redditStory objectForKey:@"url"]]];
    }
    [_webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_HUD hide:YES];
}

- (void) showCommentsView
{
    // Show the comments popup viewer
    
    CommentsViewController *commentsController = [CommentsViewController sharedClass];
    [commentsController loadCommentsForStory:_redditStory];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:commentsController];
    [navController.navigationBar setBackgroundImage:[UIImage imageNamed: @"navigationBar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:navController animated:YES completion:nil];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

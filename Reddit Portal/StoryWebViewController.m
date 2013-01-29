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

#define VIEW_COMMENTS_INDEX 0
#define VIEW_SHARE_INDEX 1
#define PRIMARY_ACTION_SHEET 1
#define SHARING_ACTION_SHEET 2
#define SHARE_VIA_EMAIL 0
#define SHARE_VIA_SMS 1

@interface StoryWebViewController ()

@end

@implementation StoryWebViewController

@synthesize storyURL = _storyURL;
@synthesize webView = _webView;
@synthesize HUD = _HUD;
@synthesize redditStory = _redditStory;

+ (StoryWebViewController *) sharedClass
{
    // Creates a singleton of this class.
    
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
                                                                             withOffset:0];
        
        UIBarButtonItem *actionBarButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                               withAction:@selector(showActionSheet)
                                                                                withImage:@"action.png"
                                                                               withOffset:10];
        
        self.navigationItem.leftBarButtonItem = backBarButton;
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:actionBarButton, nil];
        
    }
    
    return self;
}

- (void)navigationBarDoubleTap:(UIGestureRecognizer*)recognizer
{
    [YRDropdownView showDropdownInView:self.view
                                 title:[_redditStory objectForKey:@"title"]
                                detail:[NSString stringWithFormat:@"%@    comments: %@",[_redditStory objectForKey:@"author"], [_redditStory objectForKey:@"num_comments"]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)goBackToStories
{
    [self.navigationController popViewControllerAnimated:YES];
    [YRDropdownView hideDropdownInView:self.view];
}

- (void) showActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"View Comments", @"Share This Story", nil];
    sheet.tag = PRIMARY_ACTION_SHEET;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == PRIMARY_ACTION_SHEET )
    {
        if( buttonIndex == VIEW_COMMENTS_INDEX )
        {
            [self showCommentsView];
        }
        else if( buttonIndex == VIEW_SHARE_INDEX )
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Share Via Email", @"Share Via SMS", nil];
            sheet.tag = SHARING_ACTION_SHEET;
            [sheet showInView:self.view];
        }
    }
    else
    {
        if ( buttonIndex == SHARE_VIA_EMAIL )
        {
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
        }
        else if( buttonIndex == SHARE_VIA_SMS )
        {
            // Sharing via SMS
            
            if( [MFMessageComposeViewController canSendText] )
            {
                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                messageController.messageComposeDelegate = self;
                
                [messageController setBody:[_redditStory objectForKey:@"url"]];
                [self presentViewController:messageController animated:YES completion:nil];
            }
        }
    }
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
    [_HUD show:YES];
    
    NSURLRequest *request = nil;
    
    UILabel *navTitle = [[UILabel alloc] initWithTitle:[_redditStory objectForKey:@"domain"] withColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = navTitle;
    
    if ( [[_redditStory objectForKey:@"domain"] isEqualToString:@"reddit.com"] || [[_redditStory objectForKey:@"domain"] rangeOfString:@"self."].location != NSNotFound)
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Change the size of the front story table.
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        _webView.frame = CGRectMake(0, 0, 320, 415);
    }
    else
    {
        _webView.frame = CGRectMake(0, 0, 480, 270);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        _webView.frame = CGRectMake(0, 0, 320, 415);
    }
    else
    {
        _webView.frame = CGRectMake(0, 0, 480, 270);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

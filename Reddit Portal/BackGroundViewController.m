//
//  BackGroundViewController.m
//  RocketNews
//
//  Created by Travis Hoover on 12/20/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "BackGroundViewController.h"
#import "BarButtonItemObject.h"
#import "AppDelegate.h"
#import "UILabel+NavigationTitle.h"

#define NAV_TITLE @"My Reddit             "

@implementation BackGroundViewController

@synthesize backGroundTableView = _backGroundTableView;
@synthesize reddit = _reddit;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _backGroundTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 60)
                                                   style:UITableViewStylePlain];
    _backGroundTableView.delegate = self;
    _backGroundTableView.dataSource = self;
    
    _reddit = [Reddit sharedClass];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [tempImageView setFrame:_backGroundTableView.frame];
    
    [_backGroundTableView setSeparatorColor:[UIColor clearColor]];
    _backGroundTableView.backgroundView = tempImageView;
        
    //
    // Navigation Title
    //
    UILabel *navTitle = [[UILabel alloc] initWithTitle:NAV_TITLE withColor:[UIColor whiteColor]];
    self.navigationItem.titleView = navTitle;
    
    [self.view addSubview:_backGroundTableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if ([[_reddit.topSubreddits objectAtIndex:indexPath.row] isEqualToString:@"Enter Subreddit"])
    {
        UIAlertView *subreddit = [[UIAlertView alloc] initWithTitle:@"Enter Subreddit"
                                                            message:@"Do not include /r/"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Go", nil];
        
        subreddit.alertViewStyle = UIAlertViewStylePlainTextInput;
        [subreddit show];
    }
    else
    {
        [self changeSubRedditTo:[_reddit.topSubreddits objectAtIndex:indexPath.row]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( ![[alertView textFieldAtIndex:0].text isEqualToString:@""] )
    {
        [self changeSubRedditTo:[alertView textFieldAtIndex:0].text];
    }
}

- (void) changeSubRedditTo:(NSString *)subreddit
{
    [_reddit changeSubRedditTo:subreddit];
    
    SWRevealViewController *revealController = self.revealViewController;
    [revealController revealToggle:self]; // Slide back the front story view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reddit.topSubreddits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifierBackGround";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"backgroundCell.png"]
                                                 stretchableImageWithLeftCapWidth:0.0
                                                                     topCapHeight:5.0]];
    cell.textLabel.text = [_reddit.topSubreddits objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    cell.textLabel.textColor = [UIColor whiteColor];

    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

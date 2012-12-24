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

#define NAV_TITLE @"My Reddit"

@interface BackGroundViewController ()

@end

@implementation BackGroundViewController

@synthesize backGroundTableView = _backGroundTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _backGroundTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                   style:UITableViewStylePlain];
    _backGroundTableView.delegate = self;
    _backGroundTableView.dataSource = self;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [tempImageView setFrame:_backGroundTableView.frame];
    
    [_backGroundTableView setSeparatorColor:[UIColor clearColor]];
    _backGroundTableView.backgroundView = tempImageView;
        
    //
    // Navigation Title
    //
    UILabel *navTitle = [[UILabel alloc] initWithTitle:NAV_TITLE withColor:[UIColor whiteColor]];
    self.navigationItem.titleView = navTitle;
    
    
    //
    // Settings Button
    //
    self.navigationItem.leftBarButtonItem = [BarButtonItemObject createButtonItemForTarget:self.navigationController
                                                                                withAction:@selector(popViewControllerAnimated:)
                                                                                 withImage:@"settings.png"
                                                                                withOffset:5];

    
    [self.view addSubview:_backGroundTableView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if ([[[AppDelegate sharedAppdelegate].reddit.subreddits objectAtIndex:indexPath.row] isEqualToString:@"Enter Subreddit"]) {
        
        UIAlertView *subreddit = [[UIAlertView alloc] initWithTitle:@"Enter Subreddit"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Go", nil];
        
        subreddit.alertViewStyle = UIAlertViewStylePlainTextInput;
        [subreddit show];
    }
    else {
        
        [self changeSubRedditTo:[[AppDelegate sharedAppdelegate].reddit.subreddits objectAtIndex:indexPath.row]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self changeSubRedditTo:[alertView textFieldAtIndex:0].text];
}


- (void) changeSubRedditTo:(NSString *)subreddit
{
    [[AppDelegate sharedAppdelegate].reddit changeSubRedditTo:subreddit];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppDelegate sharedAppdelegate].reddit.subreddits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    static NSString *cellIdentifier = @"cellIdentifierBackGround";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"backgroundCell.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    cell.textLabel.text = [[AppDelegate sharedAppdelegate].reddit.subreddits objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    cell.textLabel.textColor = [UIColor whiteColor];

    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

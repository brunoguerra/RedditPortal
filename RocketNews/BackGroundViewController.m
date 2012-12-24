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

@interface BackGroundViewController ()

@end

@implementation BackGroundViewController

@synthesize backGroundTableView = _backGroundTableView, supportedSitesObject = _supportedSitesObject;

AppDelegate *_delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _backGroundTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                   style:UITableViewStylePlain];
    
    
    _supportedSitesObject = [[SupportedSitesObject alloc] init];
    
    //_backGroundTableView.backgroundColor = [UIColor blackColor];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [tempImageView setFrame:_backGroundTableView.frame];
    
    [_backGroundTableView setSeparatorColor:[UIColor clearColor]];
    _backGroundTableView.backgroundView = tempImageView;
    
    _backGroundTableView.delegate = self;
    _backGroundTableView.dataSource = self;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = @"My Reddit";
    [label sizeToFit];
    
    
    UIBarButtonItem *flagBarButton = [BarButtonItemObject createButtonItemForTarget:self.navigationController
                                                                         withAction:@selector(popViewControllerAnimated:)
                                                                          withImage:@"settings.png"
                                                                         withOffset:5];
    self.navigationItem.leftBarButtonItem = flagBarButton;
    
    _delegate = [[UIApplication sharedApplication] delegate];
    
    [self.view addSubview:_backGroundTableView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[_delegate.reddit.subreddits objectAtIndex:indexPath.row] isEqualToString:@"Enter Subreddit"]) {
        
        UIAlertView *subreddit = [[UIAlertView alloc] initWithTitle:@"Enter Subreddit"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Go", nil];
        
        subreddit.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [subreddit show];
        
    }
    else {
        
        [_delegate.reddit changeSubRedditTo:[_delegate.reddit.subreddits objectAtIndex:indexPath.row]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_delegate.reddit changeSubRedditTo:[alertView textFieldAtIndex:0].text];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _delegate.reddit.subreddits.count;
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
    cell.textLabel.text = [_delegate.reddit.subreddits objectAtIndex:indexPath.row];
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

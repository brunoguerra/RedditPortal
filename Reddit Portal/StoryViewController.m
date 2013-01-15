//
//  MainViewController.m
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "StoryViewController.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import <SSPullToRefresh.h>
#import "UILabel+NavigationTitle.h"
#import "TimeAgoObject.h"
#import "BarButtonItemObject.h"
#import "EmptyThumbnailObject.h"


#define AUTO_FETCH_BUFFER 5
#define SLIDE_OFFSET 230
#define SLIDE_DURATION 0.2

#define CELL_PADDING 10.0
#define TITLE_PADDING 20.0
#define THUMBNAIL_SIZE 75.0

@interface StoryViewController ()

@end

@implementation StoryViewController

@synthesize webView = _webView, storyTableView = _storyTableView, pullToRefreshView = _pullToRefreshView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[StoryWebViewController alloc] init];
    
    _storyTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                   style:UITableViewStylePlain];
    _pullToRefreshView = [[SSPullToRefreshView alloc]
                          initWithScrollView:_storyTableView
                          delegate:self];
    
    _storyTableView.delegate = self;
    _storyTableView.dataSource = self;

    
    //
    // Navigation Title
    //
    UILabel *navTitle = [[UILabel alloc] initWithTitle:[AppDelegate sharedAppdelegate].reddit.currentRedditTitle withColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = navTitle;
    
    
    UIBarButtonItem *slideButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                       withAction:@selector(toggleSlider)
                                                                        withImage:@"slider.png"
                                                                       withOffset:0];
    
    UIBarButtonItem *optionsButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                         withAction:@selector(toggleSlider)
                                                                          withImage:@"options"
                                                                         withOffset:0];
    
    self.navigationItem.leftBarButtonItem = slideButton;
    self.navigationItem.rightBarButtonItem = optionsButton;

    [self.view addSubview:_storyTableView];
}

bool isOffScreen = false;
- (void) slideRight
{
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:SLIDE_DURATION];
    [UIView setAnimationDelegate:self];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.x += SLIDE_OFFSET;
    self.navigationController.view.frame = rect;
    [UIView commitAnimations];
    isOffScreen = true;
}

- (void) slideLeft
{
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:SLIDE_DURATION];
    [UIView setAnimationDelegate:self];
    self.navigationController.view.frame = [[UIScreen mainScreen] bounds];
    [UIView commitAnimations];
    isOffScreen = false;
}

- (void) toggleSlider
{    
    if( isOffScreen ) {
        [self slideLeft];
    }
    else {
        [self slideRight];
    }
}


- (void)refresh
{
    [self.pullToRefreshView startLoading];
    [[AppDelegate sharedAppdelegate].reddit refresh];
}

- (void) stopRefreshing
{
    // TODO: Instead of creating a new label everytime just change the text of the current one.
    UILabel *navTitle = [[UILabel alloc] initWithTitle:[AppDelegate sharedAppdelegate].reddit.currentRedditTitle withColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = navTitle;

    if( isOffScreen ) {
        [self slideLeft];
    }
    
    [self.pullToRefreshView finishLoading];
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self refresh];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _webView.storyURL = [[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"url"];
    [_webView loadNewStory];
    
    [self.navigationController pushViewController:_webView
                                         animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AppDelegate sharedAppdelegate].reddit.stories.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL thumbnailEmpty = [EmptyThumbnailObject isThumbnailEmpty:[[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"thumbnail"]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    NSInteger thumbnailOffset = THUMBNAIL_SIZE + (2 * CELL_PADDING);
    if (thumbnailEmpty) {
        thumbnailOffset = CELL_PADDING;
    }
    
    titleLabel.frame = CGRectMake( thumbnailOffset , CELL_PADDING, 320 - thumbnailOffset - CELL_PADDING, 0);
    titleLabel.text = [[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"title"];
    [titleLabel sizeToFit];
    
    UILabel *authorLabel = [[UILabel alloc] init];
    authorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    authorLabel.numberOfLines = 1;
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.text = [[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"author"];
    [authorLabel sizeToFit];
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    scoreLabel.numberOfLines = 1;
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.text = [[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"domain"];
    [scoreLabel sizeToFit];
    
    CGFloat cellHeight = titleLabel.frame.size.height + authorLabel.frame.size.height + scoreLabel.frame.size.height + (2 * CELL_PADDING);
    
    
    if (!thumbnailEmpty && cellHeight < THUMBNAIL_SIZE + (2 * CELL_PADDING) ) {
        
        return THUMBNAIL_SIZE + (2 * CELL_PADDING);
    }


    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // This is where the auto fetching happens
    if ([AppDelegate sharedAppdelegate].reddit.numOfStoriesLoaded == indexPath.row + AUTO_FETCH_BUFFER) {
        
        [[AppDelegate sharedAppdelegate].reddit loadNextPage];
    }
    
    static NSString *cellIdentifier = @"cellIdentifierStories";
    
    UILabel *titleLabel = nil;
    UILabel *storyUrlLabel = nil;
    UILabel *dateLabel = nil;
    UILabel *scoreLabel = nil;
    UILabel *commentsCount = nil;
    UILabel *authorLabel = nil;
    UIImageView *imageView = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 1;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: titleLabel];

        imageView = [[UIImageView alloc] init];
        imageView.tag = 2;
        [cell.contentView addSubview: imageView];
        
        storyUrlLabel = [[UILabel alloc] init];
        storyUrlLabel.tag = 3;
        storyUrlLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        storyUrlLabel.numberOfLines = 1;
        storyUrlLabel.textColor = [UIColor darkGrayColor];
        storyUrlLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: storyUrlLabel];
        
        dateLabel = [[UILabel alloc] init];
        dateLabel.tag = 4;
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        dateLabel.numberOfLines = 1;
        dateLabel.textColor = [UIColor darkGrayColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: dateLabel];
        
        scoreLabel = [[UILabel alloc] init];
        scoreLabel.tag = 5;
        scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        scoreLabel.numberOfLines = 1;
        scoreLabel.textColor = [UIColor darkGrayColor];
        scoreLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: scoreLabel];
        
        commentsCount = [[UILabel alloc] init];
        commentsCount.tag = 6;
        commentsCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        commentsCount.numberOfLines = 1;
        commentsCount.textColor = [UIColor darkGrayColor];
        commentsCount.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: commentsCount];
        
        authorLabel = [[UILabel alloc] init];
        authorLabel.tag = 7;
        authorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        authorLabel.numberOfLines = 1;
        authorLabel.textColor = [UIColor darkGrayColor];
        authorLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: authorLabel];
        
    }
    else {
        
        titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
        imageView = (UIImageView *)[cell.contentView viewWithTag:2];
        storyUrlLabel = (UILabel *)[cell.contentView viewWithTag:3];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:4];
        scoreLabel = (UILabel *)[cell.contentView viewWithTag:5];
        commentsCount = (UILabel *)[cell.contentView viewWithTag:6];
        authorLabel = (UILabel *)[cell.contentView viewWithTag:7];
    }
    
    
    imageView.frame = CGRectMake( CELL_PADDING, CELL_PADDING, THUMBNAIL_SIZE, THUMBNAIL_SIZE);
    [imageView setImageWithURL:[NSURL URLWithString:[[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"thumbnail"]]
              placeholderImage:nil];
    


    // Calcuate the offset for the labels around the thumbnail
    NSInteger thumbnailOffset = imageView.frame.size.width + (CELL_PADDING * 2);
    BOOL thumbnailEmpty = [EmptyThumbnailObject isThumbnailEmpty:[[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"thumbnail"]];
    
    if (thumbnailEmpty) {
        thumbnailOffset = CELL_PADDING;
    }
    
    
    //
    // Title 
    //
    
    titleLabel.frame = CGRectMake( thumbnailOffset , CELL_PADDING, 320 - thumbnailOffset - CELL_PADDING, 0);
    titleLabel.text = [[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"title"];
    [titleLabel sizeToFit];
    
    NSInteger titleOffset = titleLabel.frame.size.height + TITLE_PADDING;
    
    //
    // Story url
    //
    
    storyUrlLabel.frame = CGRectMake( thumbnailOffset, titleOffset, 0, 0);
    storyUrlLabel.text = [[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"domain"];
    [storyUrlLabel sizeToFit];

    
    NSInteger runningOffset = thumbnailOffset + storyUrlLabel.frame.size.width + CELL_PADDING;
    
    
    //
    // Date Label
    //
    
    dateLabel.frame = CGRectMake(runningOffset, titleOffset, 0, 0);
    dateLabel.text = [TimeAgoObject dateDiff:[[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"created_utc"]];
    [dateLabel sizeToFit];
    
    
    runningOffset += dateLabel.frame.size.width + CELL_PADDING;
    
    //
    // Story Score
    //
    
    scoreLabel.frame = CGRectMake(runningOffset, titleOffset, 0, 0);
    scoreLabel.text = [NSString stringWithFormat:@"%@",[[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"score"]];
    [scoreLabel sizeToFit];

    
    //
    // Number of comments
    //
    
    titleOffset += storyUrlLabel.frame.size.height;
    
    commentsCount.frame = CGRectMake( thumbnailOffset, titleOffset, 0, 0);
    commentsCount.text = [NSString stringWithFormat:@"%@ comments",[[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"num_comments"]];
    [commentsCount sizeToFit];
    
    
    runningOffset = thumbnailOffset + commentsCount.frame.size.width + CELL_PADDING;
    
    //
    // Author of Post
    //
    
    authorLabel.frame = CGRectMake( runningOffset, titleOffset, 0, 0);
    authorLabel.text = [[[AppDelegate sharedAppdelegate].reddit.stories objectAtIndex:indexPath.row] objectForKey:@"author"];
    [authorLabel sizeToFit];
    
    
    [cell.contentView addSubview: imageView];
    
    
    return cell;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Change the size of the front story table.
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        _storyTableView.frame = CGRectMake(0, 0, 320, 480);
    }
    else {
        _storyTableView.frame = CGRectMake(0, 0, 480, 320);
    }
    
    NSLog(@"I am starting to rotate");
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"I have finished rotating");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

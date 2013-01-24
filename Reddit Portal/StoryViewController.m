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
#import "UILabel+TableCellLabel.h"
#import "TimeAgoObject.h"
#import "BarButtonItemObject.h"
#import "EmptyThumbnailObject.h"
#import "SWRevealViewController.h"
#import <MBProgressHUD.h>

#define AUTO_FETCH_BUFFER 5
#define CELL_PADDING 10.0
#define TITLE_PADDING 20.0
#define THUMBNAIL_SIZE 75.0
#define HUD_TEXT @"Loading"

enum SORT_ACTION {HOT, NEW, CONTROVERSIAL, TOP};
enum SORT_MENU {NOTHING, MAIN_MENU, NEW_MENU, CONTROVERSIAL_MENU, TOP_MENU};
enum NEW_MENU_OPTIONS { NEW_OPTION, RISING_OPTION };

@interface StoryViewController ()

@end

@implementation StoryViewController

@synthesize webView = _webView;
@synthesize storyTableView = _storyTableView;
@synthesize pullToRefreshView = _pullToRefreshView;
@synthesize reddit = _reddit;
@synthesize HUD = _HUD;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[StoryWebViewController alloc] init];
    
    _storyTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                   style:UITableViewStylePlain];
    _pullToRefreshView = [self createPullToRefresh];
    
    _storyTableView.delegate = self;
    _storyTableView.dataSource = self;
        
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    
    
    // Create the HUD for future use
    _HUD = [self createHUDForView:revealController.view];
    _reddit = [Reddit sharedClass];
    
    [self loadMoreStories];

    
    
    //
    // Navigation Title
    //
    UILabel *navTitle = [[UILabel alloc] initWithTitle:_reddit.subreddit withColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = navTitle;
    
    
    UIBarButtonItem *slideButton = [BarButtonItemObject createButtonItemForTarget:revealController
                                                                       withAction:@selector(revealToggle:)
                                                                        withImage:@"slider.png"
                                                                       withOffset:0];
    
    UIBarButtonItem *optionsButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                         withAction:@selector(showSortMenu)
                                                                          withImage:@"options"
                                                                         withOffset:0];
    
    self.navigationItem.leftBarButtonItem = slideButton;
    self.navigationItem.rightBarButtonItem = optionsButton;

    [self.view addSubview:_storyTableView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _webView.storyURL = [[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"url"];
    _webView.redditStory = [_reddit.stories objectAtIndex:indexPath.row];
    
    [_webView loadNewStory];
    
    [self.navigationController pushViewController:_webView
                                         animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reddit.numStoriesLoaded;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    BOOL thumbnailEmpty = [EmptyThumbnailObject isThumbnailEmpty:[[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"thumbnail"]];
    
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
    titleLabel.text = [[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"title"];
    [titleLabel sizeToFit];
    
    UILabel *authorLabel = [[UILabel alloc] init];
    authorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    authorLabel.numberOfLines = 1;
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.text = [[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"author"];
    [authorLabel sizeToFit];
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    scoreLabel.numberOfLines = 1;
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.text = [[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"domain"];
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
    if (_reddit.numStoriesLoaded == indexPath.row + AUTO_FETCH_BUFFER)
    {
        [_reddit retrieveMoreStoriesWithCompletionBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_storyTableView reloadData];
                [self.pullToRefreshView finishLoading];
            });
        }];
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
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
        
        titleLabel = [[UILabel alloc] initWithTag:1
                                         withSize:14.0
                                     withNumLines:0];

        imageView = [[UIImageView alloc] init];
        imageView.tag = 2;
        
        storyUrlLabel = [[UILabel alloc] initWithTag:3
                                            withSize:10.0
                                        withNumLines:1];
        [cell.contentView addSubview: storyUrlLabel];
        
        dateLabel = [[UILabel alloc] initWithTag:4
                                        withSize:10.0
                                    withNumLines:1];
        
        scoreLabel = [[UILabel alloc] initWithTag:5
                                         withSize:10.0
                                     withNumLines:1];
        
        commentsCount = [[UILabel alloc] initWithTag:6
                                            withSize:10.0
                                        withNumLines:1];
        
        authorLabel = [[UILabel alloc] initWithTag:7
                                          withSize:10.0
                                      withNumLines:1];
        
        [cell.contentView addSubview: titleLabel];
        [cell.contentView addSubview: imageView];
        [cell.contentView addSubview: dateLabel];
        [cell.contentView addSubview: scoreLabel];
        [cell.contentView addSubview: commentsCount];
        [cell.contentView addSubview: authorLabel];
    }
    else
    {
        titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
        imageView = (UIImageView *)[cell.contentView viewWithTag:2];
        storyUrlLabel = (UILabel *)[cell.contentView viewWithTag:3];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:4];
        scoreLabel = (UILabel *)[cell.contentView viewWithTag:5];
        commentsCount = (UILabel *)[cell.contentView viewWithTag:6];
        authorLabel = (UILabel *)[cell.contentView viewWithTag:7];
    }
    
    
    imageView.frame = CGRectMake(CELL_PADDING, CELL_PADDING, THUMBNAIL_SIZE, THUMBNAIL_SIZE);
    [imageView setImageWithURL:[NSURL URLWithString:[_reddit storyDataForIndex:indexPath.row withKey:@"thumbnail"]]
              placeholderImage:nil];
    


    // Calcuate the offset for the labels around the thumbnail
    NSInteger thumbnailOffset = imageView.frame.size.width + (CELL_PADDING * 2);
    BOOL thumbnailEmpty = [EmptyThumbnailObject isThumbnailEmpty:[_reddit storyDataForIndex:indexPath.row withKey:@"thumbnail"]];
    
    if (thumbnailEmpty) {
        thumbnailOffset = CELL_PADDING;
    }
    
    
    //
    // Title 
    //
    
    titleLabel.frame = CGRectMake( thumbnailOffset , CELL_PADDING, 320 - thumbnailOffset - CELL_PADDING, 0);
    titleLabel.text = [_reddit storyDataForIndex:indexPath.row withKey:@"title"];
    [titleLabel sizeToFit];
    
    NSInteger titleOffset = titleLabel.frame.size.height + TITLE_PADDING;
    
    //
    // Story url
    //
    
    storyUrlLabel.frame = CGRectMake( thumbnailOffset, titleOffset, 0, 0);
    storyUrlLabel.text = [_reddit storyDataForIndex:indexPath.row withKey:@"domain"];
    [storyUrlLabel sizeToFit];

    
    NSInteger runningOffset = thumbnailOffset + storyUrlLabel.frame.size.width + CELL_PADDING;
    
    
    //
    // Date Label
    //
    
    dateLabel.frame = CGRectMake(runningOffset, titleOffset, 0, 0);
    dateLabel.text = [TimeAgoObject dateDiff:[_reddit storyDataForIndex:indexPath.row withKey:@"created_utc"]];
    [dateLabel sizeToFit];
    
    
    runningOffset += dateLabel.frame.size.width + CELL_PADDING;
    
    //
    // Story Score
    //
    
    scoreLabel.frame = CGRectMake(runningOffset, titleOffset, 0, 0);
    scoreLabel.text = [NSString stringWithFormat:@"%@", [_reddit storyDataForIndex:indexPath.row withKey:@"score"]];
    [scoreLabel sizeToFit];

    
    //
    // Number of comments
    //
    
    titleOffset += storyUrlLabel.frame.size.height;
    
    commentsCount.frame = CGRectMake( thumbnailOffset, titleOffset, 0, 0);
    commentsCount.text = [NSString stringWithFormat:@"%@ comments", [_reddit storyDataForIndex:indexPath.row withKey:@"num_comments"]];
    [commentsCount sizeToFit];
    
    
    runningOffset = thumbnailOffset + commentsCount.frame.size.width + CELL_PADDING;
    
    //
    // Author of Post
    //
    
    authorLabel.frame = CGRectMake( runningOffset, titleOffset, 0, 0);
    authorLabel.text = [_reddit storyDataForIndex:indexPath.row withKey:@"author"];
    [authorLabel sizeToFit];
    
    
    [cell.contentView addSubview: imageView];
    
    
    return cell;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    // Change the size of the front story table.
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        _storyTableView.frame = CGRectMake(0, 0, 320, 480);
    }
    else
    {
        _storyTableView.frame = CGRectMake(0, 0, 480, 320);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Adding new stories to the tableview

- (void) loadMoreStories
{
    [self showLoadingHUD];
    
    // Load the inital stories
    [_reddit retrieveMoreStoriesWithCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UILabel *navTitle = [[UILabel alloc] initWithTitle:_reddit.subreddit withColor:[UIColor darkGrayColor]];
            self.navigationItem.titleView = navTitle;
            
            [_storyTableView reloadData];
            [self hideLoadingHUD];
        });
    }];
}

- (void) loadMoreStoriesIfChange
{
    if ([_reddit didSubRedditChange])
    {
        [_reddit removeStories];
        
        [self showLoadingHUD];
        
        // Load the inital stories
        [_reddit retrieveMoreStoriesWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UILabel *navTitle = [[UILabel alloc] initWithTitle:_reddit.subreddit withColor:[UIColor darkGrayColor]];
                self.navigationItem.titleView = navTitle;
                
                [_storyTableView reloadData];
                [self hideLoadingHUD];
            });
        }];
    }
}


#pragma mark - Pull To Refresh

- (SSPullToRefreshView *) createPullToRefresh
{
    SSPullToRefreshView *pullRefresh = [[SSPullToRefreshView alloc] initWithScrollView:_storyTableView
                                                                              delegate:self];
    return pullRefresh;
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{    
    [self.pullToRefreshView startLoading];
    
    [_reddit removeStories];
    [_reddit retrieveMoreStoriesWithCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // TODO: do not create a new title.
            UILabel *navTitle = [[UILabel alloc] initWithTitle:_reddit.subreddit withColor:[UIColor darkGrayColor]];
            self.navigationItem.titleView = navTitle;
            
            [_storyTableView reloadData];
            [self.pullToRefreshView finishLoading];
        });
    }];
}

#pragma mark - Sorting

- (UIActionSheet *) createActionSheetWithButtons:(NSArray *)buttons WithTag:(NSInteger)tag
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    for (int i = 0; i < [buttons count]; i++)
    {
        [sheet addButtonWithTitle:[buttons objectAtIndex:i]];
    }
    
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = buttons.count;
    
    sheet.tag = tag;
    return sheet;
}

- (void) showSortMenu
{
    UIActionSheet *sortMenu = [self createActionSheetWithButtons:[NSArray arrayWithObjects:@"Hot", @"New", @"Controversial", @"Top", nil]
                                                         WithTag:1];
    [sortMenu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == MAIN_MENU )
    {
        if( buttonIndex == NEW )
        {
            UIActionSheet *sheet = [self createActionSheetWithButtons:[NSArray arrayWithObjects:@"New", @"Rising", nil]
                                                              WithTag:NEW_MENU];
            [sheet showInView:self.view];
        }
        else if ( buttonIndex == CONTROVERSIAL || buttonIndex == TOP )
        {
            UIActionSheet *sheet = [self createActionSheetWithButtons:[NSArray arrayWithObjects:@"This Hour",
                                                                                                @"Today",
                                                                                                @"This Month",
                                                                                                @"This Year",
                                                                                                @"All Time", nil] WithTag:buttonIndex + 1];
            [sheet showInView:self.view];
        }
        else if( buttonIndex == HOT )
        {
            [_reddit changeSortFilterTo:@"" WithSortName:@"" WithSortTime:-1];
            [self loadMoreStoriesIfChange];
        }
    }
    else if( actionSheet.tag == NEW_MENU )
    {
        if ( buttonIndex == NEW_OPTION )
        {
            [_reddit changeSortFilterTo:@"new" WithSortName:@"new" WithSortTime:-1];
            [self loadMoreStoriesIfChange];
        }
        else if( buttonIndex == RISING_OPTION )
        {
            [_reddit changeSortFilterTo:@"new" WithSortName:@"rising" WithSortTime:-1];
            [self loadMoreStoriesIfChange];
        }
    }
    else if( actionSheet.tag == CONTROVERSIAL_MENU )
    {
        [_reddit changeSortFilterTo:@"controversial" WithSortName:@"controversial" WithSortTime:buttonIndex];
        [self loadMoreStoriesIfChange];
    }
    else if( actionSheet.tag == TOP_MENU )
    {
        [_reddit changeSortFilterTo:@"top" WithSortName:@"top" WithSortTime:buttonIndex];
        [self loadMoreStoriesIfChange];
    }
}

#pragma mark - Loading HUD

- (MBProgressHUD *) createHUDForView:(UIView *)view
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:hud];
    hud.delegate = self;
	hud.labelText = HUD_TEXT;
    
    return hud;
}

- (void) showLoadingHUD
{
    [_HUD show:YES];
}

- (void) hideLoadingHUD
{
    [_HUD hide:YES];
}

@end

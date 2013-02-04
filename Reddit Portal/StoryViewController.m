//
//  MainViewController.m
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <BlockAlertView.h>
#import <SSPullToRefresh.h>
#import <BlockActionSheet.h>

#import "TimeAgoObject.h"
#import "StoryTableViewCell.h"
#import "NavigationTitleView.h"
#import "StoryViewController.h"
#import "BarButtonItemObject.h"
#import "EmptyThumbnailObject.h"
#import "SWRevealViewController.h"
#import "UILabel+TableCellLabel.h"
#import "UILabel+NavigationTitle.h"

#define CELL_PADDING 10.0
#define TITLE_PADDING 20.0
#define THUMBNAIL_SIZE 75.0
#define AUTO_FETCH_BUFFER 5
#define HUD_TEXT @"Loading"

@implementation StoryViewController

@synthesize HUD = _HUD;
@synthesize reddit = _reddit;
@synthesize webView = _webView;
@synthesize storyTableView = _storyTableView;
@synthesize pullToRefreshView = _pullToRefreshView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _reddit = [Reddit sharedClass];
    _webView = [StoryWebViewController sharedClass];
    
    _storyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 60)
                                                   style:UITableViewStylePlain];
    
    _pullToRefreshView = [Resources createPullToRefreshForTable:_storyTableView withDelegate:self];
    
    _storyTableView.delegate = self;
    _storyTableView.dataSource = self;
    
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
        
    _HUD = [Resources createHUDForView:revealController.view ForCaller:self];
    self.navigationItem.titleView = [NavigationTitleView createTitleWithSubReddit:_reddit.subreddit andSortOption:_reddit.sortCategory];
    
    UIBarButtonItem *slideButton = [BarButtonItemObject createButtonItemForTarget:revealController
                                                                       withAction:@selector(revealToggle:)
                                                                        withImage:@"slider.png"
                                                                       withOffset:10];
    
    UIBarButtonItem *optionsButton = [BarButtonItemObject createButtonItemForTarget:self
                                                                         withAction:@selector(showSortMenu)
                                                                          withImage:@"options"
                                                                         withOffset:0];

    self.navigationItem.leftBarButtonItem = slideButton;
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:optionsButton, nil];

    [self.view addSubview:_storyTableView];
    [self loadMoreStories];
}

#pragma mark - TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    BOOL thumbnailEmpty = [EmptyThumbnailObject isThumbnailEmpty:[_reddit storyDataForIndex:indexPath.row withKey:@"thumbnail"]];
            
    NSInteger thumbnailOffset = THUMBNAIL_SIZE + (2 * CELL_PADDING);
    if (thumbnailEmpty)
    {
        thumbnailOffset = CELL_PADDING;
    }
    
    CGSize titleSize = [[_reddit storyDataForIndex:indexPath.row withKey:@"title"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]
                                                                              constrainedToSize:CGSizeMake(320 - thumbnailOffset - CELL_PADDING, 1000)];
    
    CGSize authorSize = [[_reddit storyDataForIndex:indexPath.row withKey:@"author"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]
                                                                                constrainedToSize:CGSizeMake(320, 1000)];
    
    CGSize domainSize = [[_reddit storyDataForIndex:indexPath.row withKey:@"domain"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]
                                                                                constrainedToSize:CGSizeMake(320, 1000)];
    
    CGFloat cellHeight = titleSize.height + authorSize.height + domainSize.height + (2 * CELL_PADDING);
    
    if (!thumbnailEmpty && cellHeight < THUMBNAIL_SIZE + (2 * CELL_PADDING) )
    {
        return THUMBNAIL_SIZE + (2 * CELL_PADDING);
    }
    
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _webView.redditStory = [_reddit.stories objectAtIndex:indexPath.row];
    
    [_webView loadNewStory];
    
    [self.navigationController pushViewController:_webView
                                         animated:YES];
}

#pragma mark - TableView Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _reddit.numStoriesLoaded;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( _reddit.numStoriesLoaded == indexPath.row + AUTO_FETCH_BUFFER )
    {        
        [self prefetchStories]; // Infinite scroll
    }
    
    static NSString *cellIdentifier = @"cellIdentifierStories";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[StoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:cellIdentifier];
    }
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:2];
    UILabel *storyUrlLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:4];
    UILabel *scoreLabel = (UILabel *)[cell.contentView viewWithTag:5];
    UILabel *commentsCount = (UILabel *)[cell.contentView viewWithTag:6];
    UILabel *authorLabel = (UILabel *)[cell.contentView viewWithTag:7];
    UILabel *subReddit = (UILabel *)[cell.contentView viewWithTag:8];
    
    imageView.frame = CGRectMake(CELL_PADDING, CELL_PADDING, THUMBNAIL_SIZE, THUMBNAIL_SIZE);
    [imageView setImageWithURL:[NSURL URLWithString:[_reddit storyDataForIndex:indexPath.row withKey:@"thumbnail"]]
              placeholderImage:nil];
    
    // Calcuate the offset for the labels around the thumbnail
    NSInteger thumbnailOffset = imageView.frame.size.width + (CELL_PADDING * 2);
    BOOL thumbnailEmpty = [EmptyThumbnailObject isThumbnailEmpty:[_reddit storyDataForIndex:indexPath.row withKey:@"thumbnail"]];
    
    if (thumbnailEmpty)
    {
        thumbnailOffset = CELL_PADDING;
    }
    
    
    titleLabel.frame = CGRectMake( thumbnailOffset , CELL_PADDING, 320 - thumbnailOffset - CELL_PADDING, 0);
    titleLabel.text = [NSString stringWithFormat:@"%@", [_reddit storyDataForIndex:indexPath.row withKey:@"title"]];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    [titleLabel sizeToFit];
    
    
    NSInteger titleOffset = titleLabel.frame.size.height + TITLE_PADDING;
    
    storyUrlLabel.frame = CGRectMake( thumbnailOffset, titleOffset, 0, 0);
    storyUrlLabel.text = [_reddit storyDataForIndex:indexPath.row withKey:@"domain"];
    [storyUrlLabel sizeToFit];
    
    
    NSInteger runningOffset = thumbnailOffset + storyUrlLabel.frame.size.width + CELL_PADDING;
    
    
    dateLabel.frame = CGRectMake(runningOffset, titleOffset, 0, 0);
    dateLabel.text = [TimeAgoObject dateDiff:[_reddit storyDataForIndex:indexPath.row withKey:@"created_utc"]];
    [dateLabel sizeToFit];
    
    
    runningOffset += dateLabel.frame.size.width + CELL_PADDING;
    
    
    scoreLabel.frame = CGRectMake(runningOffset, titleOffset, 0, 0);
    scoreLabel.text = [NSString stringWithFormat:@"%@", [_reddit storyDataForIndex:indexPath.row withKey:@"score"]];
    [scoreLabel sizeToFit];
    
    
    titleOffset += storyUrlLabel.frame.size.height;
    
    commentsCount.frame = CGRectMake( thumbnailOffset, titleOffset, 0, 0);
    commentsCount.text = [NSString stringWithFormat:@"%@ comments", [_reddit storyDataForIndex:indexPath.row withKey:@"num_comments"]];
    [commentsCount sizeToFit];
    
    
    runningOffset = thumbnailOffset + commentsCount.frame.size.width + CELL_PADDING;
    
    
    authorLabel.frame = CGRectMake( runningOffset, titleOffset, 0, 0);
    authorLabel.text = [_reddit storyDataForIndex:indexPath.row withKey:@"author"];
    [authorLabel sizeToFit];
    
    runningOffset = runningOffset + authorLabel.frame.size.width + CELL_PADDING;
    
    subReddit.frame = CGRectMake( runningOffset, titleOffset, 0, 0);
    subReddit.text = [_reddit storyDataForIndex:indexPath.row withKey:@"subreddit"];
    [subReddit sizeToFit];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Adding new stories to the TableView

- (void) loadMoreStories
{
    // The method is for loading more stories and just appending them to the end of the list.
    
    [self showLoadingHUD];
    
    // Load the inital stories
    [_reddit retrieveMoreStoriesWithCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateNavigationTitle];
            
            [_storyTableView reloadData];
            [self hideLoadingHUD];
        });
    }];
}

- (void) loadMoreStoriesIfChange
{
    // This method is for when there is a change to the subreddit and we need to wipe out all of the old stories and get new ones.
    
    if ([_reddit didSubRedditChange])
    {
        [self showLoadingHUD];
        [_reddit removeStories];
        
        // Load the inital stories
        [_reddit retrieveMoreStoriesWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self updateNavigationTitle];
                
                [_storyTableView reloadData];
                [_storyTableView setContentOffset:CGPointMake(0, 0)];
                [self hideLoadingHUD];
            });
        }];
    }
}

- (void) prefetchStories
{
    // Used to create the infinte scroll effect
    
    [_reddit retrieveMoreStoriesWithCompletionBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_storyTableView reloadData];
            [self.pullToRefreshView finishLoading];
        });
    }];
}

#pragma mark - Navigation Title

- (void) updateNavigationTitle
{
    self.navigationItem.titleView = [NavigationTitleView createTitleWithSubReddit:_reddit.subreddit
                                                                    andSortOption:_reddit.sortCategory];
}

#pragma mark - Pull To Refresh

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{    
    [self.pullToRefreshView startLoading];
    
    [_reddit removeStories];
    [_reddit retrieveMoreStoriesWithCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
                        
            [_storyTableView reloadData];
            [self.pullToRefreshView finishLoading];
        });
    }];
}

#pragma mark - Sorting

- (void) showSortMenu
{
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:nil];
    [sheet addButtonWithTitle:@"Hot" block:^{
        
        [_reddit changeSortFilterTo:@"" WithSortName:@"" WithSortTime:-1];
        [self loadMoreStoriesIfChange];
    }];
    [sheet addButtonWithTitle:@"New" block:^{
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:nil
                                                       message:nil];
        
        [alert setCancelButtonWithTitle:@"New" block:^{
            
            [_reddit changeSortFilterTo:@"new" WithSortName:@"new" WithSortTime:-1];
            [self loadMoreStoriesIfChange];
        }];
        [alert setCancelButtonWithTitle:@"Rising" block:^{
            
            [_reddit changeSortFilterTo:@"new" WithSortName:@"rising" WithSortTime:-1];
            [self loadMoreStoriesIfChange];
        }];
        [alert setDestructiveButtonWithTitle:@"Cancel" block:nil];
        [alert show];
        
    }];
    [sheet addButtonWithTitle:@"Controversial" block:^{
        [self timeAlertMenu:@"controversial"];
    }];
    [sheet addButtonWithTitle:@"Top" block:^{
        [self timeAlertMenu:@"top"];
    }];
    [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
    [sheet showInView:self.view];
}

- (void)timeAlertMenu:(NSString *)category
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:nil
                                                   message:nil];
    
    [alert addButtonWithTitle:@"This Hour" block:^{
        [_reddit changeSortFilterTo:category WithSortName:category WithSortTime:0];
        [self loadMoreStoriesIfChange];
    }];
    [alert addButtonWithTitle:@"This Day" block:^{
        [_reddit changeSortFilterTo:category WithSortName:category WithSortTime:1];
        [self loadMoreStoriesIfChange];
    }];
    [alert addButtonWithTitle:@"This Week" block:^{
        [_reddit changeSortFilterTo:category WithSortName:category WithSortTime:2];
        [self loadMoreStoriesIfChange];
    }];
    [alert addButtonWithTitle:@"This Month" block:^{
        [_reddit changeSortFilterTo:category WithSortName:category WithSortTime:3];
        [self loadMoreStoriesIfChange];
    }];
    [alert addButtonWithTitle:@"This Year" block:^{
        [_reddit changeSortFilterTo:category WithSortName:category WithSortTime:4];
        [self loadMoreStoriesIfChange];
    }];
    [alert addButtonWithTitle:@"All Time" block:^{
        [_reddit changeSortFilterTo:category WithSortName:category WithSortTime:5];
        [self loadMoreStoriesIfChange];
    }];
    [alert setDestructiveButtonWithTitle:@"Cancel" block:nil];
    [alert show];
}


#pragma mark - Loading HUD

- (void) showLoadingHUD
{
    [_HUD show:YES];
}

- (void) hideLoadingHUD
{
    [_HUD hide:YES];
}

@end

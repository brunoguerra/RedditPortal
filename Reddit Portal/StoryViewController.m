//
//  MainViewController.m
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "StoryViewController.h"
#import <AFNetworking.h>
#import <SSPullToRefresh.h>
#import "UILabel+NavigationTitle.h"
#import "UILabel+TableCellLabel.h"
#import "TimeAgoObject.h"
#import "BarButtonItemObject.h"
#import "EmptyThumbnailObject.h"
#import "SWRevealViewController.h"
#import <MBProgressHUD.h>
#import "NavigationTitleView.h"
#import "StoryTableViewCell.h"
#import <BlockActionSheet.h>
#import <BlockAlertView.h>

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
    
    _webView = [StoryWebViewController sharedClass];
    
    _storyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 60)
                                                   style:UITableViewStylePlain];
    
    _pullToRefreshView = [Resources createPullToRefreshForTable:_storyTableView withDelegate:self];
    
    _storyTableView.delegate = self;
    _storyTableView.dataSource = self;
        
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.navigationController.navigationBar addGestureRecognizer:revealController.panGestureRecognizer];
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
        

    // Create the HUD for future use
    _HUD = [Resources createHUDForView:revealController.view ForCaller:self];
    _reddit = [Reddit sharedClass];
    self.navigationItem.titleView = [NavigationTitleView createTitleWithSubReddit:_reddit.subreddit andSortOption:_reddit.sortCategory];
    
    [self loadMoreStories];

    
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
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    //
    // CGSize size = [text sizeWithFont:font
    // constrainedToSize:maximumLabelSize
    // lineBreakMode:UILineBreakModeWordWrap];
    //
    
    BOOL thumbnailEmpty = [EmptyThumbnailObject isThumbnailEmpty:[_reddit storyDataForIndex:indexPath.row withKey:@"thumbnail"]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    NSInteger thumbnailOffset = THUMBNAIL_SIZE + (2 * CELL_PADDING);
    if (thumbnailEmpty)
    {
        thumbnailOffset = CELL_PADDING;
    }
    
    titleLabel.frame = CGRectMake( thumbnailOffset , CELL_PADDING, 320 - thumbnailOffset - CELL_PADDING, 0);
    titleLabel.text = [StoryViewController parseString:[_reddit storyDataForIndex:indexPath.row withKey:@"title"]];
    [titleLabel sizeToFit];
    
    UILabel *authorLabel = [[UILabel alloc] init];
    authorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    authorLabel.numberOfLines = 1;
    authorLabel.textColor = [UIColor blackColor];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.text = [_reddit storyDataForIndex:indexPath.row withKey:@"author"];
    [authorLabel sizeToFit];
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    scoreLabel.numberOfLines = 1;
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.backgroundColor = [UIColor clearColor];
    scoreLabel.text = [_reddit storyDataForIndex:indexPath.row withKey:@"domain"];
    [scoreLabel sizeToFit];
    
    CGFloat cellHeight = titleLabel.frame.size.height + authorLabel.frame.size.height + scoreLabel.frame.size.height + (2 * CELL_PADDING);
    
    if (!thumbnailEmpty && cellHeight < THUMBNAIL_SIZE + (2 * CELL_PADDING) )
    {
        return THUMBNAIL_SIZE + (2 * CELL_PADDING);
    }

    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( _reddit.numStoriesLoaded == indexPath.row + AUTO_FETCH_BUFFER )
    {
        [self prefetchStories];
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
    
    
    //
    // Title 
    //
    
    titleLabel.frame = CGRectMake( thumbnailOffset , CELL_PADDING, 320 - thumbnailOffset - CELL_PADDING, 0);
    titleLabel.text = [StoryViewController parseString:[NSString stringWithFormat:@"%@", [_reddit storyDataForIndex:indexPath.row withKey:@"title"]]];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    [titleLabel sizeToFit];
    //titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
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
    
    runningOffset = runningOffset + authorLabel.frame.size.width + CELL_PADDING;
    
    //
    // Sub reddit of the story
    //
    
    subReddit.frame = CGRectMake( runningOffset, titleOffset, 0, 0);
    subReddit.text = [_reddit storyDataForIndex:indexPath.row withKey:@"subreddit"];
    [subReddit sizeToFit];
    
    
    [cell.contentView addSubview: imageView];
    
    
    return cell;
}




+(NSString*)parseString:(NSString*)str
{
    str  = [str stringByReplacingOccurrencesOfString:@"&ndash;" withString:@"-"];
    str  = [str stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"\""];
    str  = [str stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"\""];
    str  = [str stringByReplacingOccurrencesOfString:@"&oacute;" withString:@"o"];
    str  = [str stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    str  = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return str;
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
            
            [self updateNavigationTitle];
            
            [_storyTableView reloadData];
            [self hideLoadingHUD];
        });
    }];
}

- (void) loadMoreStoriesIfChange
{
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
    [_reddit retrieveMoreStoriesWithCompletionBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_storyTableView reloadData];
            [self.pullToRefreshView finishLoading];
        });
    }];
}

- (void) updateNavigationTitle
{
    UIView *titleView = [NavigationTitleView createTitleWithSubReddit:_reddit.subreddit andSortOption:_reddit.sortCategory];
    self.navigationItem.titleView = titleView;
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( actionSheet.tag == MAIN_MENU )
    {
        if( buttonIndex == NEW )
        {
            UIActionSheet *sheet = [Resources createActionSheetWithButtons:[NSArray arrayWithObjects:@"New", @"Rising", nil]
                                                                   WithTag:NEW_MENU
                                                                 ForCaller:self];
            [sheet showInView:self.view];
        }
        else if ( buttonIndex == CONTROVERSIAL || buttonIndex == TOP )
        {
            UIActionSheet *sheet = [Resources createActionSheetWithButtons:[NSArray arrayWithObjects:@"This Hour",
                                                                                                @"Today",
                                                                                                @"This Month",
                                                                                                @"This Year",
                                                                                                @"All Time", nil]
                                                                   WithTag:buttonIndex + 1
                                                                 ForCaller:self];
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

- (void) showLoadingHUD
{
    [_HUD show:YES];
}

- (void) hideLoadingHUD
{
    [_HUD hide:YES];
}

@end

//
//  MainViewController.m
//  RocketNews
//
//  Created by Travis Hoover on 12/18/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "StoryViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking.h>

#define AUTO_FETCH_BUFFER 5
#define SLIDE_OFFSET 230
#define SLIDE_DURATION 0.2

@interface StoryViewController ()

@end

@implementation StoryViewController

@synthesize webView = _webView, reddit = _reddit, storyTableView = _storyTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[StoryWebViewController alloc] init];
    _storyTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                   style:UITableViewStylePlain];
    
    _reddit = [[RedditAPIObject alloc] initWithTableView:_storyTableView];
    
    _storyTableView.delegate = self;
    _storyTableView.dataSource = self;
    
    [self.view addSubview:_storyTableView];

    
    /*
     * The main navigation title and buttons:
     *
     */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    label.textColor = [UIColor darkGrayColor];
    self.navigationItem.titleView = label;
    label.text = @"Front Page";
    [label sizeToFit];

    
    UIImage *slideImage = [UIImage imageNamed:@"slider.png"];
    UIButton *slideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    slideButton.bounds = CGRectMake( 0, 0, slideImage.size.width, slideImage.size.height );
    [slideButton setImage:slideImage forState:UIControlStateNormal];
    [slideButton addTarget:self action:@selector(toggleSlider) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sliderBarButton = [[UIBarButtonItem alloc] initWithCustomView:slideButton];
    self.navigationItem.leftBarButtonItem = sliderBarButton;
    
    UIImageView *optionsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"options.png"]];
    UIBarButtonItem *optionsBarButton = [[UIBarButtonItem alloc] initWithCustomView:optionsImageView];
    self.navigationItem.rightBarButtonItem = optionsBarButton;

    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate messageFromChild];
    
    [_reddit fetchFrontPage];
    
    [self addGestureRecognizers];
}


- (void)addGestureRecognizers
{
    UISwipeGestureRecognizer *rightSwipeRecognizer;
    rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(handleSwipeFromRight:)];
    [rightSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:rightSwipeRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer;
    leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(handleSwipeFromLeft:)];
    [leftSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:leftSwipeRecognizer];

}

int i = 0;
- (void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:SLIDE_DURATION];
    [UIView setAnimationDelegate:self];

    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.x += SLIDE_OFFSET;
    self.navigationController.view.frame = rect;
    [UIView commitAnimations];
    i++;
}

- (void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:SLIDE_DURATION];
    [UIView setAnimationDelegate:self];
    self.navigationController.view.frame = [[UIScreen mainScreen] bounds];
    [UIView commitAnimations];
    i++;
}

- (void) toggleSlider
{    
    if( i % 2 == 0 ) {
        [UIView beginAnimations:nil
                        context:nil];
        [UIView setAnimationDuration:SLIDE_DURATION];
        [UIView setAnimationDelegate:self];
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        rect.origin.x += SLIDE_OFFSET;
        self.navigationController.view.frame = rect;
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil
                        context:nil];
        [UIView setAnimationDuration:SLIDE_DURATION];
        [UIView setAnimationDelegate:self];
        self.navigationController.view.frame = [[UIScreen mainScreen] bounds];
        [UIView commitAnimations];
    }
    
    i++;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _webView.storyURL = [[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"url"];
    [_webView newStory];
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
    return _reddit.stories.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize maximumLabelSize = CGSizeMake(220, FLT_MAX);
    CGSize expectedLabelSize = [[[_reddit.stories objectAtIndex:indexPath.row]
                                 objectForKey:@"title"]
                                sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]
                                constrainedToSize:maximumLabelSize lineBreakMode:YES];

    if (expectedLabelSize.height + 50 < 100) {
        return 100;
    }
    

    return expectedLabelSize.height + 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // This is where the auto fetching happens
    if (_reddit.numOfStoriesLoaded == indexPath.row + AUTO_FETCH_BUFFER) {
        
        [_reddit loadNextPage];
    }
    
    static NSString *cellIdentifier = @"cellIdentifierStories";
    
    UILabel *titleLabel = nil;
    UILabel *storyUrlLabel = nil;
    UILabel *dateLabel = nil;
    UILabel *scoreLabel = nil;
    UILabel *commentsCount = nil;
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
        storyUrlLabel.textColor = [UIColor blackColor];
        storyUrlLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: storyUrlLabel];
        
        dateLabel = [[UILabel alloc] init];
        dateLabel.tag = 4;
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        dateLabel.numberOfLines = 1;
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: dateLabel];
        
        scoreLabel = [[UILabel alloc] init];
        scoreLabel.tag = 5;
        scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        scoreLabel.numberOfLines = 1;
        scoreLabel.textColor = [UIColor blackColor];
        scoreLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: scoreLabel];
        
        commentsCount = [[UILabel alloc] init];
        commentsCount.tag = 5;
        commentsCount.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        commentsCount.numberOfLines = 1;
        commentsCount.textColor = [UIColor blackColor];
        commentsCount.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: commentsCount];
        
    }
    else {
        
        titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
        imageView = (UIImageView *)[cell.contentView viewWithTag:2];
        storyUrlLabel = (UILabel *)[cell.contentView viewWithTag:3];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:4];
        scoreLabel = (UILabel *)[cell.contentView viewWithTag:5];
    }
    
    CGSize maximumLabelSize = CGSizeMake(220, FLT_MAX);
    CGSize expectedLabelSize = [[[_reddit.stories objectAtIndex:indexPath.row]
                                 objectForKey:@"title"]
                                sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]
                                constrainedToSize:maximumLabelSize lineBreakMode:YES];
    
    
    titleLabel.frame = CGRectMake(95.0, 5.0, expectedLabelSize.width, expectedLabelSize.height);
    titleLabel.text = [[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"title"];
    [titleLabel sizeToFit];
    
    
    storyUrlLabel.frame = CGRectMake(95.0, expectedLabelSize.height + 5, expectedLabelSize.width, expectedLabelSize.height);
    storyUrlLabel.text = [[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"domain"];
    [storyUrlLabel sizeToFit];

    dateLabel.frame = CGRectMake(storyUrlLabel.frame.size.width + 105, expectedLabelSize.height + 5, expectedLabelSize.width, expectedLabelSize.height);
    dateLabel.text = [self dateDiff:[[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"created_utc"]];
    [dateLabel sizeToFit];
    
    scoreLabel.frame = CGRectMake(storyUrlLabel.frame.size.width + 115 + dateLabel.frame.size.width, expectedLabelSize.height + 5, expectedLabelSize.width, expectedLabelSize.height);
    scoreLabel.text = [NSString stringWithFormat:@"%@",[[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"score"]];
    [scoreLabel sizeToFit];

    imageView.frame = CGRectMake(10.0, 10.0, 75.0f, 75.0f);
    [imageView setImageWithURL:[NSURL URLWithString:[[_reddit.stories objectAtIndex:indexPath.row] objectForKey:@"thumbnail"]]
              placeholderImage:[UIImage imageNamed:@"x"]];
    
    
    [cell.contentView addSubview: imageView];
    
    
    return cell;
}

- (NSString *)dateDiff:(NSNumber *)timestamp
{
    
    NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    NSDate *todayDate = [NSDate date];
    
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    
    if(ti < 1) {
    	return @"never";
    } else 	if (ti < 60) {
    	return @"less than a minute ago";
    } else if (ti < 3600) {
    	int diff = round(ti / 60);
    	return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
    	int diff = round(ti / 60 / 60);
    	return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
    	int diff = round(ti / 60 / 60 / 24);
    	return[NSString stringWithFormat:@"%d days ago", diff];
    }
    
    return @"never";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

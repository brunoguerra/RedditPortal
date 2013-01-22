//
//  Reddit.m
//  Reddit Portal
//
//  Created by Travis Hoover on 1/20/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import "Reddit.h"
#import <AFNetworking.h>

#define BASE_URL @"http://reddit.com/"
#define STORIES_PER_PAGE 25

@implementation Reddit

@synthesize subreddit = _subreddit, numStoriesLoaded = _numStoriesLoaded, nextPageToken = _nextPageToken, topSubreddits = _topSubreddits;

/*
 *
 * Creates a singleton of this class.
 *
 */
+ (Reddit *) sharedClass
{
    static Reddit *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[Reddit alloc] init];
    });
    return _shared;
}

- (id) init
{
    if (self = [super init]) {
        
        _stories = [[NSMutableArray alloc] init];
        _topSubreddits = [[NSMutableArray alloc] init];
        _subreddit = @"Front Page";
        _nextPageToken = @"";
        _numStoriesLoaded = 0;
        
        [self setupSubReddits];
    }
    
    return self;
}

/*
 *
 * Creates the "top" subreddits that are displayed in the background table.
 *
 */
- (void) setupSubReddits
{
    NSArray *subreddits = [[NSArray alloc] initWithObjects:@"Front Page",
                                                          @"All Reddits",
                                                      @"Enter Subreddit",
                                                                 @"Pics",
                                                                @"Funny",
                                                             @"Politics",
                                                               @"Gaming",
                                                            @"ASKReddit",
                                                            @"WorldNews",
                                                               @"Videos",
                                                                 @"IAMA",
                                                        @"TodayILearned",
                                                                  @"WTF",
                                                                  @"AWW",
                                                              @"Atheism",
                                                           @"Technology",
                                                         @"AdviceAnimal",
                                                              @"Science",
                                                                @"Music",
                                                               @"Movies",
                                                               @"BestOf", nil];
    
    _topSubreddits = [[NSMutableArray alloc] initWithArray:subreddits];
}

/*
 *
 * Changes the current subreddit to a new subreddit.
 *
 */
- (void) changeSubRedditTo:(NSString *)newSubReddit
{
    if ([newSubReddit isEqualToString:@"Front Page"])
    {
        newSubReddit = @"Front Page";
    }
    else if([newSubReddit isEqualToString:@"All Reddits"])
    {
        newSubReddit = @"All";
    }
    
    // Only update if we have a different subreddit.
    if ( ![_subreddit isEqualToString:newSubReddit] ) {
        
        NSLog(@"Changing subreddit to: %@", newSubReddit);
        
        _subreddit = newSubReddit;
        [self removeStories]; // Remove the old stories from the previous subreddit.
    }
}

/*
 *
 * Retrieves the next set of stories from reddit.
 *
 */
- (void) retrieveMoreStoriesWithCompletionBlock:(void (^)())completionBlock;
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[self getNextURL]];
    AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json)
                                                        {
                                                            NSDictionary *resultsDictionary = [[NSDictionary alloc]
                                                                                               initWithDictionary:[json valueForKeyPath:@"data"]];
             
                                                            for (NSDictionary *dic in [resultsDictionary objectForKey:@"children"])
                                                            {
                                                                [_stories addObject:[dic objectForKey:@"data"]];
                                                            }
                                                            
                                                            _nextPageToken = [resultsDictionary objectForKey:@"after"];
                                                            _numStoriesLoaded += STORIES_PER_PAGE;
                                                            completionBlock();
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                            NSLog(@"%@", [error userInfo]);
                                                        }];
    [operation start];
}

/*
 * Removes all stories in the array and sets the story counter back to 0.
 */
- (void) removeStories
{
    [_stories removeAllObjects];
    _numStoriesLoaded = 0;
}



- (NSURL *) getNextURL
{
    NSString *nextUrl = BASE_URL;
    
    // The front page doesn't have an /r/ in it.
    if ( ![_subreddit isEqualToString:@"Front Page"] )
    {
        nextUrl = [NSString stringWithFormat:@"%@r/%@", nextUrl, _subreddit];
    }
    
    nextUrl = [NSString stringWithFormat:@"%@.json", nextUrl];
    
    if (_numStoriesLoaded > 0)
    {
        nextUrl = [NSString stringWithFormat:@"%@?count=%d&after=%@", nextUrl, _numStoriesLoaded, _nextPageToken];
    }
    
    NSLog(@"Next Url: %@", nextUrl);
    
    return [NSURL URLWithString:nextUrl];
}

@end

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

enum SORTED_TIME {HOUR, DAY, WEEK, MONTH, YEAR, ALL};

@implementation Reddit

@synthesize subreddit = _subreddit;
@synthesize numStoriesLoaded = _numStoriesLoaded;
@synthesize nextPageToken = _nextPageToken;
@synthesize topSubreddits = _topSubreddits;
@synthesize subRedditChanged = _subRedditChanged;
@synthesize sortCategory = _sortCategory;
@synthesize sortName = _sortName;
@synthesize sortTime = _sortTime;

+ (Reddit *) sharedClass
{
     // Creates a singleton of this class.
    
    static Reddit *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[Reddit alloc] init];
    });
    return _shared;
}

- (id) init
{
    if (self = [super init])
    {
        _stories = [[NSMutableArray alloc] init];
        _topSubreddits = [[NSMutableArray alloc] init];
        _subreddit = @"Front Page";
        _nextPageToken = @"";
        _numStoriesLoaded = 0;
        _subRedditChanged = FALSE;
        _sortTime = @"";
        _sortName = @"";
        _sortCategory = @"";
        [self setupSubReddits];
    }
    
    return self;
}

- (void) setupSubReddits
{
    // Creates the "top" subreddits that are displayed in the background table.
    
    NSArray *subreddits = [[NSArray alloc] initWithObjects:@"Enter Subreddit",
                                                                @"Front Page",
                                                               @"All Reddits",
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

- (void) changeSubRedditTo:(NSString *)newSubReddit
{
    // Changes the current subreddit to a new subreddit.
    
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
        
        _subRedditChanged = TRUE;
        _subreddit = newSubReddit;
        [self removeStories]; // Remove the old stories from the previous subreddit.
    }
}

- (void) changeSortFilterTo:(NSString *)category WithSortName:(NSString *)name WithSortTime:(int)time
{
    // Settings the sorting options that appear in the url.    
    NSString *newTime = @"";
    
    switch (time)
    {
        case HOUR:
            newTime = @"hour";
            break;
            
        case DAY:
            newTime = @"day";
            break;
            
        case WEEK:
            newTime = @"week";
            break;
            
        case MONTH:
            newTime = @"month";
            break;
            
        case YEAR:
            newTime = @"year";
            break;
            
        case ALL:
            newTime = @"all";
            break;
            
        default:
            newTime = @"";
            break;
    }
    
    if( ![_sortTime isEqualToString:newTime] || ![_sortCategory isEqualToString:category] || ![_sortName isEqualToString:name] )
    {
        _subRedditChanged = TRUE;
    }
    
    _sortCategory = category;
    _sortName = name;
    _sortTime = newTime;
    
}


- (void) retrieveMoreStoriesWithCompletionBlock:(void (^)())completionBlock
{
    // Retrieves the next set of stories from reddit.
    
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
                                                            _numStoriesLoaded = _stories.count;
                                                            _subRedditChanged = FALSE;
                                                            completionBlock();
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                            NSLog(@"ERROR loading: %@", request);
                                                            completionBlock();
                                                        }];
    [operation start];
}

- (id) storyDataForIndex:(NSUInteger)index withKey:(NSString *)key
{
    // This is a safe methods for accessing the story data. Before
    // there would some times be crashes due to accessing elements
    // out of bounds from the table view.
    
    if ( index >= [_stories count] )
    {
        return @"";
    }
    
    return [[_stories objectAtIndex:index] objectForKey:key];
}


- (void) removeStories
{
    // Removes all stories in the array and sets the story counter back to 0.
    
    [_stories removeAllObjects];
    _numStoriesLoaded = 0;
}



- (NSURL *) getNextURL
{
    // Based on several different url setting this generates the correct url to
    // fetch the next set of stories.
    
    NSString *nextUrl = BASE_URL;
    
    // The front page doesn't have an /r/ in it.
    if ( ![_subreddit isEqualToString:@"Front Page"] )
    {
        nextUrl = [NSString stringWithFormat:@"%@r/%@", nextUrl, _subreddit];
    }
    
    if ( ![_sortCategory isEqualToString:@""] )
    {
        nextUrl = [NSString stringWithFormat:@"%@/%@/", nextUrl, _sortCategory];
    }
    
    nextUrl = [NSString stringWithFormat:@"%@.json?ios=1", nextUrl];
    
    if (![_sortName isEqualToString:@""])
    {
        nextUrl = [NSString stringWithFormat:@"%@&sort=%@", nextUrl, _sortName];
    }
    
    if ( ![_sortTime isEqualToString:@""] )
    {
        nextUrl = [NSString stringWithFormat:@"%@&t=%@", nextUrl, _sortTime];
    }
    
    if (_numStoriesLoaded > 0)
    {
        nextUrl = [NSString stringWithFormat:@"%@&count=%d&after=%@", nextUrl, _numStoriesLoaded, _nextPageToken];
    }
    
    NSLog(@"Next Url: %@", nextUrl);
    
    return [NSURL URLWithString:nextUrl];
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

@end

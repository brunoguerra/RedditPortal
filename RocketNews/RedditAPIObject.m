//
//  RedditAPIObject.m
//  RocketNews
//
//  Created by Travis Hoover on 12/19/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "RedditAPIObject.h"
#import <AFNetworking.h>
#import "AppDelegate.h"

#define STORIES_PER_PAGE 25
#define REDDIT_BASE_URL @"http://www.reddit.com/.json"

@implementation RedditAPIObject

@synthesize stories = _stories, baseURL = _baseURL, nextPageToken = _nextPageToken, numOfStoriesLoaded = _numOfStoriesLoaded;

- (id) init
{    
    if (self = [super init]) {
        
        _stories = [[NSMutableArray alloc] init];
        _baseURL = @"http://www.reddit.com/.json";
        _numOfStoriesLoaded = 0;
    }
    
    return self;
}


/*
 * We do not remove all of the objects instead we update each story and indexes 0 - 24.
 *
 * First we refetch new stories from the current base url.
 *
 */
- (void) refresh
{
    NSURL *url = [NSURL URLWithString:_baseURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                                            
                                                            NSInteger index = 0;
                                                            
                                                            NSDictionary *resultsDictionary =
                                                                [[NSDictionary alloc] initWithDictionary:[json valueForKeyPath:@"data"]];
             
                                                            [_stories removeAllObjects];
                                                            
                                                            for ( NSDictionary *dic in [resultsDictionary objectForKey:@"children"])
                                                            {
                                                                [_stories insertObject:[dic objectForKey:@"data"] atIndex:index];
                                                                index++;
                                                            }
                                                                         
                                                            _numOfStoriesLoaded = STORIES_PER_PAGE;
                                                            _nextPageToken = [resultsDictionary objectForKey:@"after"];
                                                            
                                                            AppDelegate *del = [[UIApplication sharedApplication] delegate];
                                                            [del didFinishLoadingStories];
                                                        }
                                                        failure:nil];
    [operation start];
}


/*
 *
 *
 *
 */
- (void) loadNextPage
{
    NSURL *nextPageURL = self.getNextURL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:nextPageURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                             
                                             
                                             NSDictionary *resultsDictionary = [[NSDictionary alloc] initWithDictionary:[json valueForKeyPath:@"data"]];
                                             
                                             
                                             for ( NSDictionary *dic in [resultsDictionary objectForKey:@"children"]) {
                                                 
                                                 
                                                 [_stories addObject:[dic objectForKey:@"data"]];
                                             }

                                             _nextPageToken = [resultsDictionary objectForKey:@"after"];
                                             
                                             AppDelegate *del = [[UIApplication sharedApplication] delegate];
                                            [del didFinishLoadingStories];

                                         }failure:nil];
        [operation start];
}


/*
 * Construct the url of the page we want to get stories from.
 *
 */
- (NSURL *) getNextURL
{
    _numOfStoriesLoaded += STORIES_PER_PAGE;
    
    if (_numOfStoriesLoaded == 0 || [_nextPageToken length] == 0) {
 
        return [NSURL URLWithString:_baseURL];
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?count=%d&after=%@", _baseURL, _numOfStoriesLoaded, _nextPageToken]];
}


- (void) changeSubRedditTo:(NSString *)subReddit
{
    _baseURL = [NSString stringWithFormat:@"%@/r/%@", REDDIT_BASE_URL, subReddit];
}

@end

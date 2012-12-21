//
//  RedditAPIObject.m
//  RocketNews
//
//  Created by Travis Hoover on 12/19/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "RedditAPIObject.h"
#import <AFNetworking.h>

#define STORIES_PER_PAGE 25;

@implementation RedditAPIObject

@synthesize stories = _stories, tableView = _tableView, baseURL = _baseURL, nextPageToken = _nextPageToken, numOfStoriesLoaded = _numOfStoriesLoaded;

- (id) initWithTableView:(UITableView *) tableView {
    
    if (self = [super init]) {
        
        _stories = [[NSMutableArray alloc] init];
        _baseURL = @"http://www.reddit.com/.json";
        _numOfStoriesLoaded = 0;
        _tableView = tableView;
    }
    
    return self;
}
- (void) fetchFrontPage {
    
    
    NSURL *url = [NSURL URLWithString:@"http://www.reddit.com/.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                             
                                             
                                             NSDictionary *resultsDictionary = [[NSDictionary alloc] initWithDictionary:[json valueForKeyPath:@"data"]];
                                             
                                             
                                             for ( NSDictionary *dic in [resultsDictionary objectForKey:@"children"]) {
                                                
                                                
                                                 [_stories addObject:[dic objectForKey:@"data"]];
                                             }
                                             
                                             
                                             _numOfStoriesLoaded += STORIES_PER_PAGE;
                                             _nextPageToken = [resultsDictionary objectForKey:@"after"];
                                             
                                             [_tableView reloadData];
                                         }failure:nil];
    
    [operation start];
    
}

-(NSURL *) getNextURL {
    
    _numOfStoriesLoaded += STORIES_PER_PAGE;
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?count=%d&after=%@", _baseURL, _numOfStoriesLoaded, _nextPageToken]];
}

-(void) loadNextPage {
    
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
                                             
                                             NSLog(@"Loading stories: %d", _numOfStoriesLoaded);
                                             [_tableView reloadData];
                                         }failure:nil];
        [operation start];
}

@end

//
//  RedditAPIObject.h
//  RocketNews
//
//  Created by Travis Hoover on 12/19/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedditAPIObject : NSObject

@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *nextPageToken;
@property (nonatomic, assign) NSInteger numOfStoriesLoaded;

- (void) loadNextPage;
- (void) refresh;
- (void) changeSubRedditTo:(NSString *)subReddit;

@end

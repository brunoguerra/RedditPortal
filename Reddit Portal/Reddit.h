//
//  Reddit.h
//  Reddit Portal
//
//  Created by Travis Hoover on 1/20/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RefreshTable) ();

@interface Reddit : NSObject

@property (nonatomic, copy) NSString *subreddit;
@property (nonatomic, copy) NSString *nextPageToken;
@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) NSMutableArray *topSubreddits;
@property (nonatomic, assign) NSInteger numStoriesLoaded;

+ (Reddit *) sharedClass;

- (void) setupSubReddits;
- (void) changeSubRedditTo:(NSString *)subreddit;

- (void) retrieveMoreStoriesWithCompletionBlock:(void (^)())completionBlock;
- (void) removeStories;
- (NSURL *) getNextURL;



@end

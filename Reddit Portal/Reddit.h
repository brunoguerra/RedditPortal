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
@property (nonatomic, copy) NSString *sortCategory;
@property (nonatomic, copy) NSString *sortName;
@property (nonatomic, copy) NSString *sortTime;

@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) NSMutableArray *topSubreddits;
@property (nonatomic, assign) NSInteger numStoriesLoaded;
@property (nonatomic, assign, getter=didSubRedditChange) BOOL subRedditChanged;

+ (Reddit *) sharedClass;

- (void) setupSubReddits;
- (void) changeSubRedditTo:(NSString *)subreddit;

- (void) retrieveMoreStoriesWithCompletionBlock:(void (^)())completionBlock;
- (id) storyDataForIndex:(NSUInteger)index withKey:(NSString *)key;
- (void) removeStories;
- (NSURL *) getNextURL;
- (void) changeSortFilterTo:(NSString *)category WithSortName:(NSString *)name WithSortTime:(int)time;



@end

//
//  Reddit.h
//  Reddit Portal
//
//  Created by Travis Hoover on 1/20/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RefreshTable) (UITableView *tableView);

@interface Reddit : NSObject

@property (nonatomic, retain) NSString *subreddit;
@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic) NSUInteger *storiesLoaded;

- (BOOL) removeStories;
- (void) retrieveMoreStoriesWithCompetionBlock:(RefreshTable)completionBlock;

@end

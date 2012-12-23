//
//  StoriesObject.h
//  RocketNews
//
//  Created by Travis Hoover on 12/21/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoriesObject : NSObject

@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) NSMutableArray *supportedSites;

- (void) switchSites;
- (void) loadNextPage;
- (void) switchSubPage;

@end

//
//  NavigationTitleView.m
//  Reddit Portal
//
//  Created by Travis Hoover on 1/23/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import "NavigationTitleView.h"
#import "UILabel+NavigationTitle.h"

#define SPACE_BETWEEN_WORDS 10

@implementation NavigationTitleView

+ (UIView *) createTitleWithSubReddit:(NSString *)subReddit andSortOption:(NSString *)sortOption
{
    // Combines 2 labels into 1 view such that there is a primary (darker) and a secondary (lighter, smaller).
    
    UILabel *subRedditLabel = [[UILabel alloc] initWithTitle:subReddit withColor:[UIColor darkGrayColor]];
    UILabel *sortOptionLabel = [[UILabel alloc] initWithTitle:sortOption withColor:[UIColor lightGrayColor]];
    sortOptionLabel.frame = CGRectMake(subRedditLabel.frame.size.width + SPACE_BETWEEN_WORDS,
                                       0,
                                       sortOptionLabel.frame.size.width,
                                       sortOptionLabel.frame.size.height);
    
    [subRedditLabel sizeToFit];
    [sortOptionLabel sizeToFit];
    
    UIView *naviagtionView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      subRedditLabel.frame.size.width + sortOptionLabel.frame.size.width,
                                                                      25)];
    [naviagtionView addSubview:subRedditLabel];
    [naviagtionView addSubview:sortOptionLabel];
    
    return naviagtionView;
}

@end

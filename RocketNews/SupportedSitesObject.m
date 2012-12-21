//
//  SupportedSitesObject.m
//  RocketNews
//
//  Created by Travis Hoover on 12/20/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "SupportedSitesObject.h"

@implementation SupportedSitesObject

@synthesize supportSites = _supportSites;


- (id) init {
    
    if (self = [super init]) {
        
        _supportSites = [[NSArray alloc] initWithObjects:@"Reddit", @"Hacker News", nil];
    }
    
    return self;
}

@end

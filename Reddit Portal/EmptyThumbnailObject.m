//
//  EmptyThumbnailObject.m
//  Reddit Portal
//
//  Created by Travis Hoover on 12/24/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "EmptyThumbnailObject.h"

@implementation EmptyThumbnailObject

+ (BOOL) isThumbnailEmpty:(NSString *)thumbnail
{
    BOOL thumbnailEmpty = NO;
    if ([thumbnail length] == 0 || [thumbnail isEqualToString:@"self"] || [thumbnail isEqualToString:@"default"]){
        
        thumbnailEmpty = YES;
    }
    
    return thumbnailEmpty;
}

@end

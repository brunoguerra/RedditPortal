//
//  TimeAgoObject.m
//  Reddit Portal
//
//  Created by Travis Hoover on 12/24/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "TimeAgoObject.h"

@implementation TimeAgoObject

+ (NSString *)dateDiff:(NSNumber *)timestamp
{
    
    NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    NSDate *todayDate = [NSDate date];
    
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    
    if(ti < 1) {
    	return @"never";
    } else 	if (ti < 60) {
    	return @"less than a minute ago";
    } else if (ti < 3600) {
    	int diff = round(ti / 60);
    	return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
    	int diff = round(ti / 60 / 60);
    	return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
    	int diff = round(ti / 60 / 60 / 24);
    	return[NSString stringWithFormat:@"%d days ago", diff];
    }
    
    return @"never";
}

@end

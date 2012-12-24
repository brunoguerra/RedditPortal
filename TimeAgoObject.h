//
//  TimeAgoObject.h
//  Reddit Portal
//
//  Created by Travis Hoover on 12/24/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeAgoObject : NSObject

+ (NSString *)dateDiff:(NSNumber *)timestamp;

@end

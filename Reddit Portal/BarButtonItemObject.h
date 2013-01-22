//
//  BarButtonItemObject.h
//  RocketNews
//
//  Created by Travis Hoover on 12/20/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BarButtonItemObject : NSObject

+ (UIBarButtonItem *) createButtonItemForTarget:(UIViewController *)target
                                     withAction:(SEL)method
                                      withImage:(NSString *)fileName
                                     withOffset:(NSInteger) offset;

@end

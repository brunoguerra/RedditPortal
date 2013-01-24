//
//  NavigationTitleView.h
//  Reddit Portal
//
//  Created by Travis Hoover on 1/23/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationTitleView : UIView

+ (UIView *) createTitleWithSubReddit:(NSString *)subReddit andSortOption:(NSString *)sortOption;

@end

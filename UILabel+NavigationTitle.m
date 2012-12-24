//
//  UILabel+NavigationTitle.m
//  Reddit Portal
//
//  Created by Travis Hoover on 12/24/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "UILabel+NavigationTitle.h"

@implementation UILabel (NavigationTitle)

// Add method implementations here
- (id) initWithTitle:(NSString *)title withColor:(UIColor *)color
{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        self.textColor = color;
        self.text = title;
        [self sizeToFit];
    }
    
    return self;
}

@end

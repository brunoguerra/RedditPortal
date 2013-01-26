//
//  UILabel+Helper.m
//  Reddit Portal
//
//  Created by Travis Hoover on 1/24/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import "UILabel+Helper.h"

@implementation UILabel (Helper)

// Add method implementations here
- (id) initWithTitle:(NSString *)title withColor:(UIColor *)color withFontSize:(float)size withFont:(NSString *)font
{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont fontWithName:font size:size];
        self.textColor = color;
        self.text = title;
        [self sizeToFit];
    }
    
    return self;
}

@end

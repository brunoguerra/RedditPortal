//
//  UILabel+TableCellLabel.m
//  Reddit Portal
//
//  Created by Travis Hoover on 1/22/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import "UILabel+TableCellLabel.h"

@implementation UILabel (TableCellLabel)

- (id) initWithTag:(NSUInteger)tag withSize:(float)size withNumLines:(NSUInteger)lines;
{
    if (self = [super init])
    {
        self.tag = tag;
        self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
        self.numberOfLines = lines;
        self.textColor = [UIColor darkGrayColor];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

@end

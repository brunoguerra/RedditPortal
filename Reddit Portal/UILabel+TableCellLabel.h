//
//  UILabel+TableCellLabel.h
//  Reddit Portal
//
//  Created by Travis Hoover on 1/22/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (TableCellLabel)

- (id) initWithTag:(NSUInteger)tag withSize:(float)size withNumLines:(NSUInteger)lines;

@end

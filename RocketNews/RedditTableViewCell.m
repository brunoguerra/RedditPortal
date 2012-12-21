//
//  RedditTableViewCell.m
//  RocketNews
//
//  Created by Travis Hoover on 12/19/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "RedditTableViewCell.h"

@implementation RedditTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  StoryTableViewCell.m
//  Reddit Portal
//
//  Created by Travis Hoover on 1/24/13.
//  Copyright (c) 2013 Travis Hoover. All rights reserved.
//

#import "StoryTableViewCell.h"
#import "UILabel+TableCellLabel.h"

#define PRIMARY_FONT_SIZE 14
#define SECONDARY_FONT_SIZE 10

@implementation StoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // Cell layout for the story table view
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithTag:1
                                                  withSize:PRIMARY_FONT_SIZE
                                              withNumLines:0];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 2;
        
        UILabel *storyUrlLabel = [[UILabel alloc] initWithTag:3
                                                     withSize:SECONDARY_FONT_SIZE
                                                  withNumLines:1];
        
        UILabel *dateLabel = [[UILabel alloc] initWithTag:4
                                                 withSize:SECONDARY_FONT_SIZE
                                             withNumLines:1];
        
        UILabel *scoreLabel = [[UILabel alloc] initWithTag:5
                                                  withSize:SECONDARY_FONT_SIZE
                                              withNumLines:1];
        
        UILabel *commentsCount = [[UILabel alloc] initWithTag:6
                                                     withSize:SECONDARY_FONT_SIZE
                                                 withNumLines:1];
        
        UILabel *authorLabel = [[UILabel alloc] initWithTag:7
                                                   withSize:SECONDARY_FONT_SIZE
                                               withNumLines:1];
        
        UILabel *storyNumberLabel = [[UILabel alloc] initWithTag:8
                                                        withSize:SECONDARY_FONT_SIZE
                                                    withNumLines:1];
        
        [self.contentView addSubview: storyUrlLabel];
        [self.contentView addSubview: titleLabel];
        [self.contentView addSubview: imageView];
        [self.contentView addSubview: dateLabel];
        [self.contentView addSubview: scoreLabel];
        [self.contentView addSubview: commentsCount];
        [self.contentView addSubview: authorLabel];
        [self.contentView addSubview: storyNumberLabel];
    }
    
    return self;
}

@end

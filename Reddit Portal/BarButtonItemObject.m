//
//  BarButtonItemObject.m
//  RocketNews
//
//  Created by Travis Hoover on 12/20/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "BarButtonItemObject.h"

@implementation BarButtonItemObject

+ (UIBarButtonItem *) createButtonItemForTarget:(UIViewController *)target withAction:(SEL)method withImage:(NSString *)fileName withOffset:(NSInteger) offset
{    
    UIImage *image = [UIImage imageNamed:fileName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, image.size.width + offset, image.size.height );
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bookmarkBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    return bookmarkBarButton;
}


+ (UIBarButtonItem *) createButtonItemForTarget:(UIViewController *)target withText:(NSString *)text withAction:(SEL)method withOffset:(NSInteger) offset
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, 25 + offset, 25 );
    [button setTitle:text forState:UIControlStateNormal];
    [button addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bookmarkBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return bookmarkBarButton;
}


@end

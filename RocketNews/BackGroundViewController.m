//
//  BackGroundViewController.m
//  RocketNews
//
//  Created by Travis Hoover on 12/20/12.
//  Copyright (c) 2012 Travis Hoover. All rights reserved.
//

#import "BackGroundViewController.h"

@interface BackGroundViewController ()

@end

@implementation BackGroundViewController

@synthesize backGroundTableView = _backGroundTableView, supportedSitesObject = _supportedSitesObject;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _backGroundTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]
                                                   style:UITableViewStylePlain];
    
    
    _supportedSitesObject = [[SupportedSitesObject alloc] init];
    
    //_backGroundTableView.backgroundColor = [UIColor blackColor];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [tempImageView setFrame:_backGroundTableView.frame];
    
    [_backGroundTableView setSeparatorColor:[UIColor clearColor]];
    _backGroundTableView.backgroundView = tempImageView;
    
    _backGroundTableView.delegate = self;
    _backGroundTableView.dataSource = self;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = @"Sites";
    [label sizeToFit];
    
    [self.view addSubview:_backGroundTableView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:nil
                                         animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _supportedSitesObject.supportSites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    static NSString *cellIdentifier = @"cellIdentifierBackGround";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"backgroundCell.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];

    
    cell.textLabel.text = [_supportedSitesObject.supportSites objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

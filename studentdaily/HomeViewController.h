//
//  HomeViewController.h
//  studentdaily
//
//  Created by Hao Liu on 12/24/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"

@interface HomeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UIScrollView *sidebarView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) CustomNavigationBar *navbar;

@property (strong, nonatomic) NSArray *array;

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableArray *buttons;

@end

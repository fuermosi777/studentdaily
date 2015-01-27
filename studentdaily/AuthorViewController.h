//
//  AuthorViewController.h
//  studentdaily
//
//  Created by Hao Liu on 1/22/15.
//  Copyright (c) 2015 Hao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"

@interface AuthorViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CustomNavigationBar *navbar;
@property (strong, nonatomic) NSString *authorID;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) UITableView *table;

@end

//
//  NavViewController.h
//  studentdaily
//
//  Created by Hao Liu on 12/24/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavViewController : UINavigationController

@property (strong, nonatomic) UIView *over;

- (void)setBgColor:(float)percentage;
- (void)setOpaque;
- (void)setTransparent;

@end

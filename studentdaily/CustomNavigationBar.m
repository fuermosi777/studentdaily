//
//  CustomNavigationBar.m
//  studentdaily
//
//  Created by Hao Liu on 1/6/15.
//  Copyright (c) 2015 Hao Liu. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0.69 blue:0.81 alpha:0];
    }
    return self;
}

- (void)setTitle:(NSString *)text {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 44)];
    [title setCenter:CGPointMake(self.frame.size.width / 2, 44)];
    [title setText:text];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor: [UIColor whiteColor]];
    [title setFont:[UIFont systemFontOfSize:18]];
    [self addSubview:title];
}

- (void)setBgAlpha:(float)percentage {
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0.69 blue:0.81 alpha:percentage]];
}

@end

//
//  NavViewController.m
//  studentdaily
//
//  Created by Hao Liu on 12/24/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import "NavViewController.h"

@interface NavViewController ()

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationBar setShadowImage:[UIImage new]];
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    _over = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [_over setBackgroundColor:[UIColor clearColor]];
    [self.view insertSubview:_over belowSubview:self.navigationBar];
    
    // set color
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:18], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationBar.titleTextAttributes = attributes;
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBgColor:(float)percentage {
    [_over setBackgroundColor:[UIColor colorWithRed:0 green:0.69 blue:0.81 alpha:percentage]];
}

- (void)setOpaque {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:(UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         
                     }
                     completion:^(BOOL finished) {
                         [_over setBackgroundColor:[UIColor colorWithRed:0 green:0.69 blue:0.81 alpha:1]];
                     }
     ];
}

- (void)setTransparent {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:(UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         
                     }
                     completion:^(BOOL finished) {
                         [_over setBackgroundColor:[UIColor colorWithRed:0 green:0.69 blue:0.81 alpha:0]];
                     }
     ];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

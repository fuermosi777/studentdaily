//
//  WebViewController.h
//  studentdaily
//
//  Created by Hao Liu on 12/28/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"

@interface WebViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSURL *URL;
@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) CustomNavigationBar *navbar;

- (id)initWithURL:(NSURL *)URL;

@end

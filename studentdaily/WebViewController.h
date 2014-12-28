//
//  WebViewController.h
//  studentdaily
//
//  Created by Hao Liu on 12/28/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (strong, nonatomic) NSURL *URL;
@property (strong, nonatomic) UIWebView *webView;

@end

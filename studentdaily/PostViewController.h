//
//  PostViewController.h
//  studentdaily
//
//  Created by Hao Liu on 12/24/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) UIImageView *banner;

@end

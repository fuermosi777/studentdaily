//
//  PostViewController.m
//  studentdaily
//
//  Created by Hao Liu on 12/24/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import "PostViewController.h"
#import <MBProgressHUD/MBProgressHUD.h> // progress indicator
#import <SDWebImage/UIImageView+WebCache.h>
#import "NavViewController.h"

@interface PostViewController ()

@end

@implementation PostViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [(NavViewController *)self.navigationController setBgColor:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];

    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)addWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _webView.scrollView.delegate = self;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [_webView.scrollView setContentInset:UIEdgeInsetsMake(self.view.frame.size.width * 3/4, 0, 0, 0)];
    _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.view.frame.size.width * 3/4, 0, 0, 0);

    [self.view addSubview:_webView];
    [_webView.scrollView setContentOffset:CGPointMake(0, -self.view.frame.size.width)];// !!! don't know why, but avoid scrollview scroll to bottom in the first place
}

- (void)addBanner {
    
    _banner = [[UIImageView alloc] initWithFrame:CGRectMake(0, -self.view.frame.size.width * 1/8, self.view.frame.size.width, self.view.frame.size.width)];
    [_banner setBackgroundColor:[UIColor whiteColor]];
    [_banner setContentMode:UIViewContentModeScaleAspectFill];
    [_banner setClipsToBounds:YES];
    [_webView insertSubview:_banner atIndex:0];
    
    // overlay
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _banner.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor],
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor],
                       nil];
    [_banner.layer insertSublayer:gradient atIndex:0];
    
    // title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.width * 3/5, self.view.frame.size.width - 30, _banner.frame.size.height * 1/3)];
    [title setText:[_dict objectForKey:@"title"]];
    [title setFont:[UIFont boldSystemFontOfSize:20]];
    [title setNumberOfLines:0];
    [title sizeToFit];
    [title setTextColor:[UIColor whiteColor]];
    [_banner addSubview:title];
}

- (void)loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // send url request
        NSString *urlString = [[NSString stringWithFormat:@"http://xun-wei.com/studentdaily/post/%@/",_postID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                
                NSError *error = nil;
                
                // 先输出array，然后第0位的才是dict
                _dict = [NSJSONSerialization JSONObjectWithData:data
                                                        options:kNilOptions
                                                          error:&error];
                
                // load complete
                [self loadComplete];
            });
        } else {
            NSLog(@"load fail");
            [hud hide:YES];
        }
        
    });
}

- (void)loadComplete {
    [self addWebView];
    [self addBanner];
    [_banner sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"photo"]]]];
    
    NSString *embedHTML = [_dict objectForKey:@"css"];
    embedHTML = [embedHTML stringByAppendingString:[_dict objectForKey:@"content"]];
    [_webView loadHTMLString:embedHTML baseURL:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float originY = scrollView.contentOffset.y + self.view.frame.size.width * 3/4;
    NSLog(@"%f",originY);
    float percentage = originY/100;
    [(NavViewController *)self.navigationController setBgColor:percentage];
    
    if (originY >= -self.view.frame.size.width * 1/8) {
        // scroll indicator
        if (originY >= self.view.frame.size.width * 3/4) {
            [_webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        } else {
            [_webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.view.frame.size.width * 3/4 - originY, 0, 0, 0)];
        }
        
        // scroll banner
        [_banner setFrame:CGRectMake(0, -self.view.frame.size.width * 1/8 - originY * 0.6, self.view.frame.size.width, self.view.frame.size.width)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

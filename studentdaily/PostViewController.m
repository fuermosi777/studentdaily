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
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * 3/4, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _webView.scrollView.delegate = self;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view insertSubview:_webView aboveSubview:_banner];
}

- (void)addBanner {
    _banner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 3/4)];
    [_banner setContentMode:UIViewContentModeScaleAspectFill];
    [_banner setClipsToBounds:YES];
    [self.view addSubview:_banner];
    
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
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, _banner.frame.size.height * 2/3, self.view.frame.size.width - 30, _banner.frame.size.height * 1/3)];
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
    [self addBanner];
    [self addWebView];
    [_banner sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"photo"]]]];
    
    NSString *embedHTML = [_dict objectForKey:@"css"];
    embedHTML = [embedHTML stringByAppendingString:[_dict objectForKey:@"content"]];
    [_webView loadHTMLString:embedHTML baseURL:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float percentage = scrollView.contentOffset.y/100;
        [(NavViewController *)self.navigationController setBgColor:percentage];
    
    // scroll webview
    if (self.view.frame.size.width * 3/4 - scrollView.contentOffset.y > 0) {
        [_webView setFrame:CGRectMake(0, self.view.frame.size.width * 3/4 - scrollView.contentOffset.y, self.view.frame.size.width, _webView.frame.size.height)];
    } else {
        [_webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    }
    
        // scroll banner
    [_banner setFrame:CGRectMake(0, 0 - scrollView.contentOffset.y, self.view.frame.size.width, self.view.frame.size.width * 3/4)];
    
    if (scrollView.contentOffset.y  <= 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
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

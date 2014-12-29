//
//  WebViewController.m
//  studentdaily
//
//  Created by Hao Liu on 12/28/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import "WebViewController.h"
#import <MBProgressHUD/MBProgressHUD.h> // progress indicator

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        _URL = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addWebView];
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)addWebView {
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_webView];
}

- (void)loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:_URL];
        [_webView loadRequest:request];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
    });
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

//
//  WebViewController.m
//  studentdaily
//
//  Created by Hao Liu on 12/28/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//

#import "WebViewController.h"
#import <MBProgressHUD/MBProgressHUD.h> // progress indicator
#import <ionicons/IonIcons.h>

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
}

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
    [self addNavbar];
    // Do any additional setup after loading the view.
}

- (void)addNavbar {
    _navbar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [_navbar setBgAlpha:1];
    [self.view addSubview:_navbar];
    
    [_navbar setTitle:@"关于"];
    
    // add left button
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 27, 30, 30)];
    UILabel *left = [IonIcons labelWithIcon:icon_ios7_arrow_back size:30.0f color:[UIColor whiteColor]];
    [button addSubview:left];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_navbar addSubview:button];
}

- (void)addWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
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

- (void)goBack {
    [[self navigationController] popViewControllerAnimated:YES];
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

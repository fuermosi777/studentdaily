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
#import "UMSocial.h"
#import <HTMLReader/HTMLReader.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomNavigationBar.h"
#import <ionicons/IonIcons.h>

@interface PostViewController () <UMSocialUIDelegate>

@end

@implementation PostViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    [self addRightButton];
    [self addWebView];
    [self addBanner];
    [self loadData];
    [self addNavbar];
}

- (void)addNavbar {
    _navbar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.view addSubview:_navbar];
    
    [_navbar setTitle:@""];
    
    // add left button
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 27, 30, 30)];
    UILabel *left = [IonIcons labelWithIcon:icon_ios7_arrow_back size:30.0f color:[UIColor whiteColor]];
    [button addSubview:left];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_navbar addSubview:button];
}

- (void)addRightButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(share)];
    self.navigationItem.rightBarButtonItem = rightButton;
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
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor],
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor],
                       (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8] CGColor],
                       nil];
    [_banner.layer insertSublayer:gradient atIndex:0];
    
    // title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.width * 3/5, self.view.frame.size.width - 30, _banner.frame.size.height * 1/3)];
    [title setText:[_dict objectForKey:@"title"]];
    [title setFont:[UIFont boldSystemFontOfSize:20]];
    [title setNumberOfLines:0];
    [title sizeToFit];
    [title setTextColor:[UIColor whiteColor]];
    [title.layer setShadowColor:[UIColor blackColor].CGColor];
    [title.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [title.layer setMasksToBounds:NO];
    [title.layer setShadowRadius:3.0];
    [title.layer setShadowOpacity:0.5];
    [_banner addSubview:title];
    
    // author
    UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.width * 7/8 - 20, self.view.frame.size.width - 30, 20)];
    [author setText:[NSString stringWithFormat:@"来自: %@", [_dict objectForKey:@"author"]]];
    [author setFont:[UIFont systemFontOfSize:10]];
    [author setTextColor:[UIColor lightGrayColor]];
    [author setNumberOfLines:0];
    [author sizeToFit];
    [_banner addSubview:author];
}

#pragma mark - share

- (void)share {
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"549cda13fd98c5b8d0000ff8"
                                      shareText:@"分享自学生日报"
                                     shareImage:_banner.image
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatFavorite,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                       delegate:self];
    [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"http://studentdaily.org/post/%@/",[_dict objectForKey:@"id"]];
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"http://studentdaily.org/post/%@/",[_dict objectForKey:@"id"]];
    [UMSocialData defaultData].extConfig.wechatSessionData.title = [NSString stringWithFormat:@"%@", [_dict objectForKey:@"title"]];
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = [NSString stringWithFormat:@"%@", [_dict objectForKey:@"title"]];
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

- (BOOL)isDirectShareInIconActionSheet {
    return YES;
}

#pragma mark -

- (void)loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // send url request
        [_banner sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"photo"]]]];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[_dict objectForKey:@"url"]]];
        NSString *webString= [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        HTMLDocument *document = [HTMLDocument documentWithString:webString];
        HTMLSelector *selector = [HTMLSelector selectorForString:@".rich_media_content"];
        HTMLDocument *content = [[document nodesMatchingParsedSelector:selector] objectAtIndex:0];
        
        NSString *contentString = content.innerHTML;
        /*
        NSArray *attributeList = [NSArray arrayWithObjects:@"style",@"class",@"width",@"height",@"align",@"bgcolor", nil];
        // remove attrs
        for (NSString *attribute in attributeList) {
            NSString *pattern = [NSString stringWithFormat:@" %@=\"[^>\"]*\"",attribute];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
            contentString = [regex stringByReplacingMatchesInString:contentString
                                                            options:0
                                                              range:NSMakeRange(0, [contentString length])
                                                       withTemplate:@""];
        }
        
        NSRegularExpression *regexClick = [NSRegularExpression regularExpressionWithPattern:@"<p>点击标题[^<]*</p>" options:0 error:NULL];
        contentString = [regexClick stringByReplacingMatchesInString:contentString
                                                                   options:0
                                                                     range:NSMakeRange(0, [contentString length])
                                                              withTemplate:@""];
        
        contentString= [contentString stringByReplacingOccurrencesOfString:@"data-src" withString:@"src"];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"<section>" withString:@"<p>"];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"</section>" withString:@"</p>"];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"<span>" withString:@""];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"<blockquote>" withString:@"<p>"];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"</blockquote>" withString:@"</p>"];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"<fieldset>" withString:@""];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"</fieldset>" withString:@""];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"<strong>" withString:@""];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
        contentString = [contentString stringByReplacingOccurrencesOfString:@"<p><br></p>" withString:@""];
         */
        contentString = [[NSString stringWithFormat:@"%@",[_dict objectForKey:@"css"]] stringByAppendingString:contentString];
        NSLog(@"%@",contentString);
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [_webView loadHTMLString:contentString baseURL:nil];
            // load complete
        });
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float originY = scrollView.contentOffset.y + self.view.frame.size.width * 3/4;
    float percentage = originY/100;
    [_navbar setBgAlpha:percentage];
    
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

- (void)goBack {
    [[self navigationController] popViewControllerAnimated:YES];
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

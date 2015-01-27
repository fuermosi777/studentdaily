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
#import "WebViewController.h"
#import "AuthorViewController.h"

@interface PostViewController () <UMSocialUIDelegate>

@end

@implementation PostViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    [self addRightButton];
}

- (void)addRightButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 15 - 30, 27, 30, 30)];
    UILabel *left = [IonIcons labelWithIcon:icon_ios7_upload_outline size:30.0f color:[UIColor whiteColor]];
    [button addSubview:left];
    [button addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [_navbar addSubview:button];
}

- (void)addWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
    _webView.scrollView.delegate = self;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [_webView.scrollView setContentInset:UIEdgeInsetsMake(self.view.frame.size.width * 3/4 + 60, 0, 0, 0)];
    _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.view.frame.size.width * 3/4, 0, 0, 0);

    [self.view addSubview:_webView];
    [_webView.scrollView setContentOffset:CGPointMake(0, -self.view.frame.size.width)];// !!! don't know why, but avoid scrollview scroll to bottom in the first place
}

- (void)addAuthorBar {
    _authorBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width * 3/4, self.view.frame.size.width, 60)];
    [_authorBar setBackgroundColor: [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1]];
    
    // avatar
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 30, 30)];
    [avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"avatar"]]]];
    [_authorBar addSubview:avatar];
    [avatar setClipsToBounds:YES];
    [avatar.layer setCornerRadius:15];
    
    // author
    UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 200, 20)];
    [author setText:[NSString stringWithFormat:@"公众号: %@", [_dict objectForKey:@"author"]]];
    [author setTextColor:[UIColor colorWithRed:0 green:0.62 blue:0.85 alpha:1]];
    [author setFont:[UIFont systemFontOfSize:14]];
    [_authorBar addSubview:author];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redirectToAuthor:)];
    [author setTag: [[_dict objectForKey:@"authorID"] intValue]];
    [author setUserInteractionEnabled:YES];
    [author addGestureRecognizer:tap];
    
    // redirect
    UIButton *redirect = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, 20, 100, 20)];
    [redirect setTitle:@"查看原文 >" forState:UIControlStateNormal];
    [redirect setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [redirect.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_authorBar addSubview:redirect];
    [redirect addTarget:self action:@selector(redirectToOrigin) forControlEvents:UIControlEventTouchUpInside];
    
    [_webView addSubview:_authorBar];
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

#pragma mark - load

- (void)loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // send url request
        [_banner sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"photo"]]]];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[_dict objectForKey:@"url"]]];
        //NSLog(@"%@",url);
        NSString *webString= [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        HTMLDocument *document = [HTMLDocument documentWithString:webString];
        HTMLSelector *selector = [HTMLSelector selectorForString:@".rich_media_content"];
        NSArray *contentArray = [NSArray arrayWithArray:[document nodesMatchingParsedSelector:selector]];
        if ([contentArray count] > 0) {
            HTMLDocument *content = [contentArray objectAtIndex:0];
            NSString *contentString = content.innerHTML;
            contentString = [[NSString stringWithFormat:@"%@",[_dict objectForKey:@"css"]] stringByAppendingString:contentString];
            NSLog(@"%@",contentString);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [_webView loadHTMLString:contentString baseURL:nil];
                // load complete
                [self addAuthorBar];
            });
        } else {
            [hud hide:YES];
            [self goBack];
        }
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float originY = scrollView.contentOffset.y + self.view.frame.size.width * 3/4 + 60;
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
    
    [_authorBar setFrame:CGRectMake(0, self.view.frame.size.width * 3/4 - originY, self.view.frame.size.width, 60)];
}

- (void)goBack {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)redirectToOrigin {
    WebViewController *vc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"url"]]]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)redirectToAuthor:(UITapGestureRecognizer *)tap {
    AuthorViewController *vc = [[AuthorViewController alloc] init];
    [vc setAuthorID: [NSString stringWithFormat:@"%li", (long)tap.view.tag]];
    [self.navigationController pushViewController:vc animated:YES];
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

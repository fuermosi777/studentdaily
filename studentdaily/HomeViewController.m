//
//  HomeViewController.m
//  studentdaily
//
//  Created by Hao Liu on 12/24/14.
//  Copyright (c) 2014 Hao Liu. All rights reserved.
//
#define LISTITEMHEIGHT 100
#define LIST 0
#define BANNERNUM 5
#define BUTTONHEIGHT 50

#import "HomeViewController.h"
#import <MBProgressHUD/MBProgressHUD.h> // progress indicator
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostViewController.h"
#import "NavViewController.h"
#import "WebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import <ionicons/IonIcons.h>
#import "CustomNavigationBar.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _keyword = @"精选";
    
    [self addContent];
    [self addTable];
    [self addSidebar];
    [self addBanner];
    [self addNavbar];
    [self loadData];
    
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
}

- (void)addNavbar {
    _navbar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 3/4, 0, self.view.frame.size.width, 64)];
    [_contentView addSubview:_navbar];
    
    [_navbar setTitle:@"学生日报"];
    
    // add left button
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 27, 30, 30)];
    UILabel *left = [IonIcons labelWithIcon:icon_ios7_bookmarks_outline size:30.0f color:[UIColor whiteColor]];
    [button addSubview:left];
    [button addTarget:self action:@selector(showSidebar) forControlEvents:UIControlEventTouchUpInside];
    [_navbar addSubview:button];
}

- (void)addContent {
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height + 20)];
    [_contentView setBackgroundColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1]];
    [_contentView setContentSize:CGSizeMake(self.view.frame.size.width * 7/4, self.view.frame.size.height - 64)];
    [_contentView setShowsHorizontalScrollIndicator:YES];
    [_contentView setPagingEnabled:YES];
    [_contentView setContentOffset:CGPointMake(self.view.frame.size.width * 3/4, 0)];
    [_contentView setDelegate:self];
    [_contentView setShowsVerticalScrollIndicator:NO];
    [_contentView setBounces:NO];
    [_contentView setShowsHorizontalScrollIndicator:NO];
    [_contentView setAlwaysBounceHorizontal:NO];
    [self.view addSubview:_contentView];
}

- (void)addTable {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 3/4, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.contentInset = UIEdgeInsetsMake(self.view.frame.size.width * 3/4, 0, 0, 0);
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.clipsToBounds = NO;
    _tableView.layer.masksToBounds = NO;
    _tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    _tableView.layer.shadowOffset = CGSizeMake(0, 0);
    _tableView.layer.shadowOpacity = 0.4;
    _tableView.layer.shadowRadius = 3.0f;
    [_contentView addSubview:_tableView];
}

- (void)addBanner {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, - self.view.frame.size.width * 7/8, self.view.frame.size.width, self.view.frame.size.width)];
    [_tableView insertSubview:_scrollView atIndex:0];
}

- (void)addSidebar {
    // sidebar
    _sidebarView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width * 3/4, self.view.frame.size.height)];
    [_contentView addSubview:_sidebarView];
    // data init
    _categories = [NSArray arrayWithObjects:@"精选",@"科技",@"媒体",@"娱乐",@"生活",@"学习",@"历史",@"金融",@"美食",@"电影",@"海外",@"设计",@"时尚",@"旅行", nil];
    // start init labels
    [_sidebarView setContentSize:CGSizeMake(_sidebarView.frame.size.width, BUTTONHEIGHT * ([_categories count] + 2))];
    
    _buttons = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_categories count]; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, BUTTONHEIGHT * i, _sidebarView.frame.size.width, BUTTONHEIGHT)];
        [button setTitle:[_categories objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            [button setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
        }
        
        [_sidebarView addSubview:button];
        [_buttons addObject:button];
    }
    
    // add bottom
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 3/4, 64)];
    [_contentView addSubview:bottomBar];
    bottomBar.layer.masksToBounds = NO;
    bottomBar.layer.shadowColor = [UIColor blackColor].CGColor;
    bottomBar.layer.shadowOffset = CGSizeMake(0, 1);
    bottomBar.layer.shadowOpacity = 0.4;
    bottomBar.layer.shadowRadius = 3.0f;
    [bottomBar setBackgroundColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1]];
    
    /*
    UIButton *collectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, bottomBar.frame.size.width/2, bottomBar.frame.size.height)];
    [collectBtn setTitle:@"收藏" forState:UIControlStateNormal];
    [collectBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [collectBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    UILabel *star = [IonIcons labelWithIcon:icon_ios7_star_outline size:20.0f color:[UIColor lightGrayColor]];
    [star setCenter:CGPointMake(30, bottomBar.frame.size.height / 2)];
    [collectBtn addSubview:star];
    [bottomBar addSubview:collectBtn];
    */
    UIButton *aboutBtn = [[UIButton alloc] initWithFrame:CGRectMake(bottomBar.frame.size.width/2, 10, bottomBar.frame.size.width/2, bottomBar.frame.size.height)];
    [aboutBtn setCenter:CGPointMake(bottomBar.frame.size.width/2, 40)]; // center
    [aboutBtn addTarget:self action:@selector(redirectToAboutView) forControlEvents:UIControlEventTouchUpInside];
    [aboutBtn setTitle:@"关于" forState:UIControlStateNormal];
    [aboutBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [aboutBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    UILabel *info = [IonIcons labelWithIcon:icon_ios7_information_outline size:20.0f color:[UIColor lightGrayColor]];
    [info setCenter:CGPointMake(30, bottomBar.frame.size.height / 2)];
    [aboutBtn addSubview:info];
    [bottomBar addSubview:aboutBtn];
}

- (void)reloadBanner {
    NSArray *viewsToRemove = [_scrollView subviews];
    for (UIView *v in viewsToRemove) [v removeFromSuperview];
    // add top banner
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width * BANNERNUM, self.view.frame.size.width)];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    for (int i = 0; i < BANNERNUM; i++) {
        NSDictionary *dict = [_array objectAtIndex:i];
        // photo
        UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.width)];
        [photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dict objectForKey:@"photo"]]]];
        [photo setClipsToBounds:YES];
        [photo setContentMode:UIViewContentModeScaleAspectFill];
        [_scrollView addSubview:photo];
        
        // overlay
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = photo.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor],
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor],
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8] CGColor],
                           nil];
        [photo.layer insertSublayer:gradient atIndex:0];
        
        // title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.width * 3/5, self.view.frame.size.width - 30, self.view.frame.size.height * 1/3)];
        [title setText:[dict objectForKey:@"title"]];
        [title setFont:[UIFont boldSystemFontOfSize:20]];
        [title setNumberOfLines:0];
        [title sizeToFit];
        [title setTextColor:[UIColor whiteColor]];
        [title.layer setShadowColor:[UIColor blackColor].CGColor];
        [title.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        [title.layer setMasksToBounds:NO];
        [title.layer setShadowRadius:3.0];
        [title.layer setShadowOpacity:0.5];
        [photo addSubview:title];
        
        // author
        UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.width * 7/8 - 20, self.view.frame.size.width - 30, 20)];
        [author setText:[NSString stringWithFormat:@"来自: %@", [dict objectForKey:@"author"]]];
        [author setFont:[UIFont systemFontOfSize:10]];
        [author setTextColor:[UIColor lightGrayColor]];
        [author setNumberOfLines:0];
        [author sizeToFit];
        [photo addSubview:author];
        
        // tag
        photo.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [photo setUserInteractionEnabled:YES];
        [photo addGestureRecognizer:tap];
    }
}

- (void)loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // send url request
        NSString *urlString = [[NSString stringWithFormat:@"http:/studentdaily.org/api/post/list/?keyword=%@",_keyword] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                
                NSError *error = nil;
                
                // 先输出array，然后第0位的才是dict
                NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions
                                                                          error:&error];
                
                // store to local
                NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
                [userInfo setValue:array forKey:@"post"];
                [userInfo synchronize];
                
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

    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    _array = [userInfo objectForKey:@"post"];
    [self reloadBanner];
    [_tableView reloadData];
}

#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    NSInteger num;
    if (_array) {
        num = [_array count];
    } else {
        num = 1;
    }
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowHeight;
    switch (indexPath.section) {
        case LIST:
            rowHeight = LISTITEMHEIGHT;
            break;
        default:
            break;
    }
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case LIST:
        {
            NSDictionary *dict = [_array objectAtIndex:indexPath.row];
            // item
            UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, LISTITEMHEIGHT)];
            UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, item.frame.size.width * 3/4, LISTITEMHEIGHT)];
            UIView *right = [[UIView alloc] initWithFrame:CGRectMake(item.frame.size.width * 3/4, 0, item.frame.size.width * 1/4, LISTITEMHEIGHT)];
            [item addSubview:left];
            [item addSubview:right];
            // title
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, left.frame.size.width - 30, 40)];
            [title setText:[dict objectForKey:@"title"]];
            [title setNumberOfLines:2];
            [title sizeToFit];
            [left addSubview:title];
            
            // author
            UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(15, LISTITEMHEIGHT - 35, left.frame.size.width - 30, 20)];
            [author setText:[NSString stringWithFormat:@"来自: %@", [dict objectForKey:@"author"]]];
            [author setTextColor:[UIColor grayColor]];
            [author setFont:[UIFont systemFontOfSize:12]];
            [left addSubview:author];
            
            // date
            /*
            UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(15, LISTITEMHEIGHT - 35, left.frame.size.width - 30, 20)];
            [date setText:[NSString stringWithFormat:@"%@", [dict objectForKey:@"date"]]];
            [date setTextAlignment:NSTextAlignmentRight];
            [date setTextColor:[UIColor grayColor]];
            [date setFont:[UIFont systemFontOfSize:12]];
            [left addSubview:date];
            */
            
            // photo
            UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, right.frame.size.width - 15, LISTITEMHEIGHT - 30)];
            [photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dict objectForKey:@"photo"]]]];
            [photo setClipsToBounds:YES];
            [photo setContentMode:UIViewContentModeScaleAspectFill];
            [right addSubview:photo];
            
            [cell addSubview:item];
            [cell setTag:indexPath.row];
            break;
        }
        default:
            break;
    }

    return cell;
}

- (void)tap:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag;
    [self redirectToPost:index];
}

- (void)buttonSelected:(UIButton *)button {
    _keyword = button.titleLabel.text;
    
    [button setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];

    for (UIButton *b in _buttons) {
        if (![b.titleLabel.text isEqualToString:_keyword]) {
            [b setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    [self hideSidebar];
    [_tableView setContentOffset:CGPointMake(0, -self.view.frame.size.width * 3/4) animated:YES];
    [self loadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case LIST:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            // accident click
            if (_contentView.contentOffset.x < self.view.frame.size.width * 3/4 - 20) {
                [self hideSidebar];
            } else {
                [self redirectToPost:cell.tag];
            }
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _contentView) {
        if (scrollView.contentOffset.x == 0) {
            [_tableView setScrollEnabled:NO];
            [_scrollView setScrollEnabled:NO];
            [_tableView setUserInteractionEnabled:NO];
            
        } else {
            [_tableView setScrollEnabled:YES];
            [_scrollView setScrollEnabled:YES];
            [_tableView setUserInteractionEnabled:YES];
        }
    }
    if (scrollView == _tableView) {
        
        float originY = scrollView.contentOffset.y + self.view.frame.size.width * 3/4;
        float percentage = originY/100;
        [_navbar setBgAlpha:percentage];
        
        if (originY < 0) {
            [_scrollView setFrame:CGRectMake(0, - self.view.frame.size.width * 7/8 + originY * 0.8, self.view.frame.size.width, self.view.frame.size.width)];
        } else {
            [_scrollView setFrame:CGRectMake(0, - self.view.frame.size.width * 7/8 + originY * 0.6, self.view.frame.size.width, self.view.frame.size.width)];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    float originY = scrollView.contentOffset.y + self.view.frame.size.width * 3/4 + 64;
    if (originY < -20) {
        [self loadData];
    }
}

#pragma mark - redirect

- (void)redirectToPost:(NSInteger)index {
    PostViewController *vc = [[PostViewController alloc] init];
    [vc setDict:[_array objectAtIndex:index]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)redirectToAboutView {
    WebViewController *vc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:@"http://studentdaily.org/web/copyright/"]];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)showSidebar {
    [_contentView setContentOffset:CGPointMake(0, _contentView.contentOffset.y) animated:YES];
}
- (void)hideSidebar {
    [_contentView setContentOffset:CGPointMake(self.view.frame.size.width * 3/4, _contentView.contentOffset.y) animated:YES];
}

#pragma mark - other

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

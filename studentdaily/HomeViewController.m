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

#import "HomeViewController.h"
#import <MBProgressHUD/MBProgressHUD.h> // progress indicator
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostViewController.h"
#import "NavViewController.h"
#import "AboutTableViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTable];
    [self addBanner];
    [self loadData];
    [self addRightButton];
    
    self.navigationItem.title = @"留学生日报";
}

- (void)addTable {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 64)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.contentInset = UIEdgeInsetsMake(self.view.frame.size.width * 3/4, 0, 0, 0);
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
}

- (void)addBanner {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, - self.view.frame.size.width * 7/8, self.view.frame.size.width, self.view.frame.size.width)];
    [_tableView insertSubview:_scrollView atIndex:0];
}

- (void)addRightButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                 target:self
                                                                                 action:@selector(redirectToAboutView)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)reloadBanner {
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
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] CGColor],
                           (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor],
                           nil];
        [photo.layer insertSublayer:gradient atIndex:0];
        
        // title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.size.width * 3/5, self.view.frame.size.width - 30, self.view.frame.size.height * 1/3)];
        [title setText:[dict objectForKey:@"title"]];
        [title setFont:[UIFont boldSystemFontOfSize:20]];
        [title setNumberOfLines:0];
        [title sizeToFit];
        [title setTextColor:[UIColor whiteColor]];
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
        photo.tag = [[dict objectForKey:@"id"] intValue];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [photo setUserInteractionEnabled:YES];
        [photo addGestureRecognizer:tap];
    }
}

- (void)loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // send url request
        NSString *urlString = [[NSString stringWithFormat:@"http:/studentdaily.org/api/post/list/"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
            UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(15, LISTITEMHEIGHT - 35, left.frame.size.width - 30, 20)];
            [date setText:[NSString stringWithFormat:@"%@", [dict objectForKey:@"date"]]];
            [date setTextAlignment:NSTextAlignmentRight];
            [date setTextColor:[UIColor grayColor]];
            [date setFont:[UIFont systemFontOfSize:12]];
            [left addSubview:date];
            
            // photo
            UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, right.frame.size.width - 15, LISTITEMHEIGHT - 30)];
            [photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dict objectForKey:@"photo"]]]];
            [photo setClipsToBounds:YES];
            [photo setContentMode:UIViewContentModeScaleAspectFill];
            [right addSubview:photo];
            
            [cell addSubview:item];
            [cell setTag:[[dict objectForKey:@"id"] intValue]];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tap:(UITapGestureRecognizer *)tap {
    NSString *ID = [NSString stringWithFormat:@"%ld",(long)tap.view.tag];
    [self redirectToPost:ID];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case LIST:
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [self redirectToPost:[NSString stringWithFormat:@"%ld",(long)cell.tag]];
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float originY = scrollView.contentOffset.y + self.view.frame.size.width * 3/4 + 64;
    //NSLog(@"%f,%f,%f",scrollView.contentOffset.y,originY,- self.view.frame.size.width * 7/8 + originY * 0.6);
    float percentage = originY / 100;
    [(NavViewController *)self.navigationController setBgColor:percentage];
    
    if (originY < 0) {
        [_scrollView setFrame:CGRectMake(0, - self.view.frame.size.width * 7/8 + originY * 0.8, self.view.frame.size.width, self.view.frame.size.width)];
    } else {
        [_scrollView setFrame:CGRectMake(0, - self.view.frame.size.width * 7/8 + originY * 0.6, self.view.frame.size.width, self.view.frame.size.width)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    float originY = scrollView.contentOffset.y + self.view.frame.size.width * 3/4 + 64;
    if (originY < -70) {
        [self loadData];
    }
}

#pragma mark - redirect

- (void)redirectToPost:(NSString *)postID {
    PostViewController *vc = [[PostViewController alloc] init];
    [vc setPostID:postID];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)redirectToAboutView {
    AboutTableViewController *vc = [[AboutTableViewController alloc] initWithStyle:UITableViewStyleGrouped];

    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:vc animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                     }];
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

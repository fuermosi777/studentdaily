//
//  AuthorViewController.m
//  studentdaily
//
//  Created by Hao Liu on 1/22/15.
//  Copyright (c) 2015 Hao Liu. All rights reserved.
//
#define LISTITEMHEIGHT 100
#define BANNERHEIGHT 180

#import "AuthorViewController.h"
#import "CustomNavigationBar.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <ionicons/IonIcons.h>
#import "WebViewController.h"
#import <MBProgressHUD/MBProgressHUD.h> // progress indicator

@interface AuthorViewController ()

@end

@implementation AuthorViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadData];
    [self addTableView];
    
    [self addNavbar];
    // Do any additional setup after loading the view.
}

- (void)addNavbar {
    _navbar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [self.view addSubview:_navbar];
    
    [_navbar setTitle:@""];
    [_navbar setBgAlpha:1];
    
    // add left button
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, 27, 30, 30)];
    UILabel *left = [IonIcons labelWithIcon:icon_ios7_arrow_back size:30.0f color:[UIColor whiteColor]];
    [button addSubview:left];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_navbar addSubview:button];
}

- (void)addTableView {
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _table.dataSource = self;
    _table.delegate = self;
    [_table setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    [self.view addSubview:_table];
}

#pragma mark - load

- (void)loadData {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // send url request
        NSString *urlString = [[NSString stringWithFormat:@"http:/studentdaily.org/api/author/%@/",_authorID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlString];
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                
                NSError *error = nil;
                
                _dict = [NSJSONSerialization JSONObjectWithData:data
                                                        options:kNilOptions
                                                          error:&error];
                
                _array = [_dict objectForKey:@"post"];
                
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
    [_table reloadData];
}

- (void)goBack {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - table
// 表格section数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    height = BANNERHEIGHT;
                    break;
                }
                case 1:
                {
                    height = 44;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            height = LISTITEMHEIGHT;
            break;
        }
        default:
            height = 44;
            break;
    }

    return height;
}

// row num
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numberOfRow;
    if (section == 0) {
        numberOfRow = 1;
    } else if (section == 1) {
        numberOfRow = (int)[_array count];
    }
    return numberOfRow;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:@"Cell"];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    if (_dict) {
                        float width = self.view.frame.size.width / 4;
                        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-width)/2, 20, width, width)];
                        [avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"photo"]]]];
                        [cell addSubview:avatar];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40 + width, self.view.frame.size.width, 20)];
                        [label setText:[NSString stringWithFormat:@"%@", [_dict objectForKey:@"name"]]];
                        [label setFont:[UIFont systemFontOfSize:16]];
                        [label setTextColor:[UIColor colorWithRed:0 green:0.62 blue:0.85 alpha:1]];
                        [label setTextAlignment:NSTextAlignmentCenter];
                        [cell addSubview:label];
                    }
                    
                    break;
                }
                case 1:
                {
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
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
            [cell setTag:indexPath.row];
            break;
        }
        default:
            break;
    }
    
    
    // cancel highlight
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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

//
//  JDOShipViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-9-12.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOShipViewController.h"
#import "JDOHttpClient.h"
#import "TFHpple.h"
#import "JDOShipTableCell.h"

@interface JDOShipViewController ()

@end

@implementation JDOShipViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHex:Main_Background_Color]];
    
    UILabel *beglabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 50.0, 80.0, 35.0)];
    [beglabel setBackgroundColor:[UIColor clearColor]];
    [beglabel setText:@"起始时间："];
    [beglabel setFont:[UIFont systemFontOfSize:15.0]];
    [beglabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    UILabel *endlabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 95.0, 80.0, 35.0)];
    [endlabel setBackgroundColor:[UIColor clearColor]];
    [endlabel setText:@"起始时间："];
    [endlabel setFont:[UIFont systemFontOfSize:15.0]];
    [endlabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    
    [self.view addSubview:beglabel];
    [self.view addSubview:endlabel];
    
    begtime = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 50.0, 140.0, 35.0)];
    [begtime setFont:[UIFont systemFontOfSize:15.0]];
    begtime.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    begtime.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    endtime = [[UITextField alloc] initWithFrame:CGRectMake(110.0, 95.0, 140.0, 35.0)];
    [endtime setFont:[UIFont systemFontOfSize:15.0]];
    endtime.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    endtime.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:begtime];
    [self.view addSubview:endtime];
    [begtime setText:@"2013/09/30"];
    [endtime setText:@"2013/09/30"];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20.0, 140.0, 280, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"livehood_continue_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"查 询" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    
    [self.view addSubview:button];

    table = [[UITableView alloc] initWithFrame:CGRectMake(20, 190, 280, App_Height - 200)];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setBounces:NO];
    [table setHidden:YES];
    [self.view addSubview:table];
}

// 所有有导航栏的界面navigationView都应该在视图层级的最后添加或者bringToFront
- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToParent)];
    [self.navigationView setTitle:@"船运时刻查询"];
}

- (void)backToParent
{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count -2] animated:true];
}

- (void)submit
{
    //NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSURL *baseurl = [[NSURL alloc] initWithString:@"http://www.bohaiferry.com/"];
    JDOHttpClient *client = [[JDOHttpClient alloc] initWithBaseURL:baseurl];
    NSDictionary *params = @{@"beg_tim": begtime.text, @"end_tim": endtime.text, @"Submit": @"查询"};
    [client postPath:@"hangyun/ship.asp" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSString *html = [[NSString alloc] initWithData:responseObject encoding:enc];
        //NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:responseObject encoding:@"GB2312"];
        tableArray = [hpple searchWithXPathQuery:@"//tr[@bgcolor='#F0F0F0']"];
        
        [begtime resignFirstResponder];
        [endtime resignFirstResponder];
        [table reloadData];
        [table setHidden:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}



#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ShipTableCell";
        
    JDOShipTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[JDOShipTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    [cell setData:[tableArray objectAtIndex:indexPath.row]];
    [cell setSeparator:nil];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return tableArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

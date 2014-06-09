//
//  JDOShipViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-9-12.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOShipViewController.h"
#import "JDOHttpClient.h"
#import "UIView+Common.h"
#import "TFHpple.h"
#import "JDOShipTableCell.h"
#import "ActionSheetDatePicker.h"

@interface JDOShipViewController ()

@end

@implementation JDOShipViewController

@synthesize beg_date = _beg_date;
@synthesize end_date = _end_date;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.beg_date = [NSDate date];
        self.end_date = [NSDate date];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHex:Main_Background_Color]];
    float y = Is_iOS7?20:0;
    
    UILabel *beglabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, y+50.0, 80.0, 35.0)];
    [beglabel setBackgroundColor:[UIColor clearColor]];
    [beglabel setText:@"起始时间："];
    [beglabel setFont:[UIFont systemFontOfSize:15.0]];
    [beglabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    UILabel *endlabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, y+95.0, 80.0, 35.0)];
    [endlabel setBackgroundColor:[UIColor clearColor]];
    [endlabel setText:@"结束时间："];
    [endlabel setFont:[UIFont systemFontOfSize:15.0]];
    [endlabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    
    [self.view addSubview:beglabel];
    [self.view addSubview:endlabel];
    
    begtime = [[UITextField alloc] initWithFrame:CGRectMake(110.0, y+50.0, 190.0, 35.0)];
    [begtime setFont:[UIFont systemFontOfSize:15.0]];
    [begtime setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"inputFidldBorder"]]];
    begtime.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    begtime.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [begtime setTag:9009];
    [begtime setDelegate:self];
    [begtime addTarget:self action:@selector(selectBegDate:) forControlEvents:UIControlEventTouchDown];
    [begtime setText:[dateFormatter stringFromDate:self.beg_date]];
    
    endtime = [[UITextField alloc] initWithFrame:CGRectMake(110.0, y+95.0, 190.0, 35.0)];
    [endtime setFont:[UIFont systemFontOfSize:15.0]];
    endtime.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    endtime.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [endtime setTag:9010];
    [endtime setDelegate:self];
    [endtime addTarget:self action:@selector(selectEndDate:) forControlEvents:UIControlEventTouchDown];
    [endtime setText:[dateFormatter stringFromDate:self.end_date]];
    
    [self.view addSubview:begtime];
    [self.view addSubview:endtime];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20.0, y+140.0, 280, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"livehood_continue_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"查 询" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    
    [self.view addSubview:button];

    table = [[UITableView alloc] initWithFrame:CGRectMake(20, y+190, 280, App_Height - 200)];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setBounces:NO];
    [table setHidden:YES];
    [self.view addSubview:table];
}

- (void)selectBegDate:(id)sender
{
    ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:self.beg_date target:self action:@selector(beg_dateWasSelected:) origin:sender];
    [actionSheetPicker addCustomButtonWithTitle:@"今天" value:[NSDate date]];
    actionSheetPicker.hideCancel = YES;
    [actionSheetPicker showActionSheetPicker];
}

- (void)selectEndDate:(id)sender
{
    ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:self.end_date target:self action:@selector(end_dateWasSelected:) origin:sender];
    [actionSheetPicker addCustomButtonWithTitle:@"今天" value:[NSDate date]];
    actionSheetPicker.hideCancel = YES;
    [actionSheetPicker showActionSheetPicker];
}

#warning 日期范围应该限制在7天以内，选的时间段太长会导致数据加载量大，界面卡死
- (void)beg_dateWasSelected:(NSDate *)selectedDate {
    self.beg_date = selectedDate;
    NSString *destDateString = [dateFormatter stringFromDate:self.beg_date];
    begtime.text = destDateString;
}

- (void)end_dateWasSelected:(NSDate *)selectedDate {
    self.end_date = selectedDate;
    NSString *destDateString = [dateFormatter stringFromDate:self.end_date];
    endtime.text = destDateString;
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
    NSURL *baseurl = [[NSURL alloc] initWithString:@"http://www.bohaiferry.com/"];
    JDOHttpClient *client = [[JDOHttpClient alloc] initWithBaseURL:baseurl];
    NSDictionary *params = @{@"beg_tim": begtime.text, @"end_tim": endtime.text, @"Submit": @"查询"};
    [client postPath:@"hangyun/ship.asp" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

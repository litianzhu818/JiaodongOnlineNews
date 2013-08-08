//
//  JDOViolationViewController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOViolationViewController.h"
#import "JDOJsonClient.h"
#import "JDOViolationTableCell.h"
#import "JDOCarManagerViewController.h"
#import "JDOCommonUtil.h"

@interface JDOViolationViewController ()

@end

@implementation JDOViolationViewController

- (id)initwithStatus:(BOOL)isaddcar
{
    addCarStatus = isaddcar;
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        types = [[NSArray alloc] init];
        types = @[@"大型汽车",@"小型汽车",@"使馆汽车",@"领馆汽车",@"境外汽车",@"外籍汽车",@"两、三轮摩托车",@"轻便摩托车",@"使馆摩托车",@"领馆摩托车",@"境外摩托车",@"外籍摩托车",@"农用运输车",@"拖拉机",@"挂车",@"教练汽车",@"教练摩托车",@"实验汽车",@"实验摩托车",@"临时入境汽车",@"临时入境摩托车",@"临时行驶车",@"公安警车",@"公安警车",@"其他"];
    }
    return self;
}

- (void)setCartype:(NSString *)type index:(int)index
{
    [CarType setTitle:type forState:UIControlStateNormal];
    [CarType setTitle:type forState:UIControlStateSelected];
    NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"0"];
    if (index < 10) {
        [tmp appendString:[NSString stringWithFormat:@"%d", index]];
        CarTypeString = tmp;
    } else {
        CarTypeString = [NSString stringWithFormat:@"%d", index];
    }
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ChassisNum setKeyboardType:UIKeyboardTypeNumberPad];
    [carnumlabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    [cartypelabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    [chassisnumlabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    [CarType setTitleColor:[UIColor colorWithHex:@"000000"] forState:UIControlStateNormal];
    [CarType setTitleColor:[UIColor colorWithHex:@"000000"] forState:UIControlStateSelected];
    CarType.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 26);
    
    CarTypeString = [[NSMutableString alloc] initWithString:@"02"];
    resultArray = [[NSMutableArray alloc] init];
    
    checkBox1 = [[M13Checkbox alloc] initWithTitle:@"保存车辆信息" andHeight:18];
    [checkBox1 setTitleColor:Light_Blue_Color];
    [checkBox1 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox1.frame = CGRectMake(15, 145, checkBox1.frame.size.width, checkBox1.frame.size.height);
    [tp addSubview:checkBox1];
    
    checkBox2 = [[M13Checkbox alloc] initWithTitle:@"接收违章推送" andHeight:18];
    [checkBox2 setTitleColor:Light_Blue_Color];
    [checkBox2 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox2.frame = CGRectMake(161, 145, checkBox2.frame.size.width, checkBox2.frame.size.height);
    [tp addSubview:checkBox2];
    
    [tp setScrollEnabled:NO];
    
    [result setBounces:NO];
    [result setDataSource:self];
    [result setDelegate:self];
    
    [result setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [result setHidden:YES];
    [resultline setHidden:YES];
    [resultline_shadow setHidden:YES];
    [no_result_image setHidden:YES];
    
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 294, 45)];
    [header setImage:[UIImage imageNamed:@"vio_result_label"]];
    UILabel *resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(106, 12, 90, 20)];
    [resultlabel setText:@"查询结果"];
    [resultlabel setTextColor:[UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:1.0]];
    [resultlabel setFont:[UIFont systemFontOfSize:20.0]];
    [resultlabel setBackgroundColor:[UIColor clearColor]];
    [header addSubview:resultlabel];
    [result setTableHeaderView:header];
    
    
    if (addCarStatus) {
        [checkBox1 setHidden:YES];
        [checkBox2 setHidden:YES];
        [searchbutton setTitle:@"添  加" forState:UIControlStateNormal];
        [searchbutton setTitle:@"添  加" forState:UIControlStateSelected];
    }
}

- (void)setupNavigationView
{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView addRightButtonImage:@"vio_head_btn" highlightImage:@"vio_head_btn" target:self action:@selector(onRightBtnClick)];
    [self.navigationView setTitle:@"违章查询"];
}

- (void) onBackBtnClick
{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    if (addCarStatus) {
        JDOCarManagerViewController *controller = (JDOCarManagerViewController *)[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count - 2];
        [controller update];
        [centerViewController popToViewController:controller animated:true];
    } else {
        [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count - 2] animated:true];
    }
}

- (void) onRightBtnClick
{
    JDOCarManagerViewController *carmanager = [[JDOCarManagerViewController alloc] initWithNibName:nil bundle:nil];
    carmanager.back = self;
    [self.navigationController pushViewController:carmanager animated:YES];
}

- (IBAction)selectCarType:(id)sender
{
    stringpicker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择号牌种类" rows:types initialSelection:1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [CarType setTitle:[types objectAtIndex:selectedIndex] forState:UIControlStateNormal];
        [CarType setTitle:[types objectAtIndex:selectedIndex] forState:UIControlStateSelected];
        NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"0"];
        if (selectedIndex < 9) {
            [tmp appendString:[NSString stringWithFormat:@"%d", selectedIndex + 1]];
            CarTypeString = tmp;
        } else {
            CarTypeString = [NSString stringWithFormat:@"%d", selectedIndex + 1];
        }
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
    
    [stringpicker showActionSheetPicker];
}

- (IBAction)sendToServer:(id)sender
{
    CarNumString = [[NSMutableString alloc] initWithString:CarNum.text];
    ChassisNumString = [[NSMutableString alloc] initWithString:ChassisNum.text];
    
    if( ![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return;
    }
    if ([self checkEmpty]) {
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:CarNumString forKey:@"hphm"];
    [params setValue:CarTypeString forKey:@"cartype"];
    [params setValue:ChassisNumString forKey:@"vin"];
    
    if (addCarStatus) {
        [self saveCarMessage:@{@"hphm":CarNumString, @"cartype":CarTypeString, @"vin":ChassisNumString, @"cartypename":CarType.titleLabel.text}];
        [self onBackBtnClick];
        return;
    }
    
    [result setHidden:YES];
    [resultline setHidden:YES];
    [resultline_shadow setHidden:YES];
    [no_result_image setHidden:YES];
    
    [[JDOJsonClient sharedClient] getPath:VIOLATION_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[(NSDictionary *)responseObject objectForKey:@"status"] isKindOfClass:[NSNumber class]]) {
            NSArray *datas = [(NSDictionary *)responseObject objectForKey:@"data"];
            [defaultback setHidden:YES];
            [resultline_shadow setHidden:NO];
            [resultline setHidden:NO];
            if (datas.count > 0) {
                [result setHidden:NO];
                [resultArray removeAllObjects];
                [resultArray addObjectsFromArray:datas];
                [result reloadData];
            } else if (datas.count == 0) {
                [no_result_image setHidden:NO];
            }
        } else {
            NSLog(@"wrongParams%@",params);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [CarNum resignFirstResponder];
    [ChassisNum resignFirstResponder];
    if (checkBox1.isChecked) {
        [self saveCarMessage:@{@"hphm":CarNumString, @"cartype":CarTypeString, @"vin":ChassisNumString, @"cartypename":CarType.titleLabel.text}];
    }
    // 设置违章推送
    [[JDOJsonClient sharedClient] getPath:BINDVIOLATIONINFO_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[(NSDictionary *)responseObject objectForKey:@"status"] isKindOfClass:[NSNumber class]]) {
            NSArray *datas = [(NSDictionary *)responseObject objectForKey:@"data"];
            [defaultback setHidden:YES];
            [resultline_shadow setHidden:NO];
            [resultline setHidden:NO];
            if (datas.count > 0) {
                [result setHidden:NO];
                [resultArray removeAllObjects];
                [resultArray addObjectsFromArray:datas];
                [result reloadData];
            } else if (datas.count == 0) {
                [no_result_image setHidden:NO];
            }
        } else {
            NSLog(@"wrongParams%@",params);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)saveCarMessage:(NSDictionary *)carMessage
{
    if (self.readCarMessage) {
        BOOL isExisted = NO;
        for (int i = 0; i < carMessageArray.count; i++) {
            if ([[carMessageArray objectAtIndex:i] isEqualToDictionary:carMessage]) {
                isExisted = YES;
            }
        }
        if (!isExisted) {
            [carMessageArray addObject:carMessage];
        }
    } else {
        carMessageArray = [[NSMutableArray alloc] init];
        [carMessageArray addObject:carMessage];
    }
    [NSKeyedArchiver archiveRootObject:carMessageArray toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"CarMessage"]];
    carMessageArray = nil;
}

- (BOOL) readCarMessage{
    carMessageArray = [NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"CarMessage"]];
    return (carMessageArray != nil);
}

- (BOOL)checkEmpty
{
    if (CarNumString.length < 7) {
        [JDOCommonUtil showHintHUD:@"车牌号输入错误" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return YES;
    }
    if (ChassisNumString.length < 4){
        [JDOCommonUtil showHintHUD:@"车架号输入错误" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return YES;
    }
    return NO;
}

- (void)setData:(NSDictionary *)data
{
    [CarType.titleLabel setText:[data objectForKey:@"cartypename"]];
    CarTypeString = [data objectForKey:@"cartype"];
    [CarNum setText:[data objectForKey:@"hphm"]];
    [ChassisNum setText:[data objectForKey:@"vin"]];
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (resultArray.count > 0) {
        NSString *cellIdentifier = @"ViolationTableCell";
        
        JDOViolationTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[JDOViolationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSDictionary *temp = [resultArray objectAtIndex:indexPath.row];
        [cell setData:temp];
        if (indexPath.row == resultArray.count - 1) {
            [cell setSeparator:[UIImage imageNamed:@"vio_line_wavy"]];
        } else {
            [cell setSeparator:nil];
        }
        UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView = backView;
        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"COUNT:%d", resultArray.count);
	return resultArray.count;
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

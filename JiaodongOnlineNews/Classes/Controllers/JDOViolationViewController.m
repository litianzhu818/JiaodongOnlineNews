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
#import "UIView+Common.h"

@interface JDOViolationViewController ()

@end

@implementation JDOViolationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        types = @[@"大型汽车",@"小型汽车",@"使馆汽车",@"领馆汽车",@"境外汽车",@"外籍汽车",@"两、三轮摩托车",@"轻便摩托车",@"使馆摩托车",@"领馆摩托车",@"境外摩托车",@"外籍摩托车",@"农用运输车",@"拖拉机",@"挂车",@"教练汽车",@"教练摩托车",@"实验汽车",@"实验摩托车",@"临时入境汽车",@"临时入境摩托车",@"临时行驶车",@"公安警车",@"公安警车",@"其他"];
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)info
{
    self.info = info;
    return [self initWithNibName:nil bundle:nil];
}

- (void)setCartype:(NSString *)type index:(int)index
{
    [CarType setTitle:type forState:UIControlStateNormal];
    NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"0"];
    if (index < 10) {
        [tmp appendString:[NSString stringWithFormat:@"%d", index]];
        CarTypeString = tmp;
    } else {
        CarTypeString = [[NSString stringWithFormat:@"%d", index] mutableCopy];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    self.mainView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];

    NSString *btnBackground = Is_iOS7?@"wide_btn~iOS7":@"wide_btn";
    [searchbutton setBackgroundImage:[UIImage imageNamed:btnBackground] forState:UIControlStateNormal];
    [searchbutton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchbutton.titleLabel setShadowOffset:Is_iOS7?CGSizeMake(0, 0):CGSizeMake(0, -1)];
    
    [CarNum addTarget:self action:@selector(changeToUpperCase:) forControlEvents:UIControlEventEditingDidEnd];
    
    [ChassisNum setKeyboardType:UIKeyboardTypeNumberPad];
    [carnumlabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    [cartypelabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    [chassisnumlabel setTextColor:[UIColor colorWithHex:Light_Blue_Color]];
    [CarType setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [CarType setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    CarType.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
    
    CarTypeString = [[NSMutableString alloc] initWithString:@"02"];
    resultArray = [[NSMutableArray alloc] init];
    
    checkBox1 = [[M13Checkbox alloc] initWithTitle:@"保存车辆信息" andHeight:18];
    [checkBox1 setTitleColor:Light_Blue_Color];
    [checkBox1 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox1.frame = CGRectMake(13, CGRectGetMaxY(ChassisNum.frame)+12, checkBox1.frame.size.width, checkBox1.frame.size.height);
    [self.mainView addSubview:checkBox1];
    
    checkBox2 = [[M13Checkbox alloc] initWithTitle:@"违章自动提醒" andHeight:18];
    [checkBox2 setTitleColor:Light_Blue_Color];
    [checkBox2 setCheckAlignment:M13CheckboxAlignmentLeft];
    checkBox2.frame = CGRectMake(320-13-checkBox2.frame.size.width, CGRectGetMaxY(ChassisNum.frame)+12, checkBox2.frame.size.width, checkBox2.frame.size.height);
    [self.mainView addSubview:checkBox2];
    
    // 默认选中两个复选框
    [checkBox1 setCheckState:M13CheckboxStateChecked];
    [checkBox2 setCheckState:M13CheckboxStateChecked];
    [checkBox1 addTarget:self action:@selector(checkBoxChanged:) forControlEvents:UIControlEventValueChanged];
    [checkBox2 addTarget:self action:@selector(checkBoxChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.mainView setScrollEnabled:NO];
    
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
    
    //xib中设置的图片不能自动适应iphone5,重新设置
    [no_result_image setImage:[UIImage imageNamed:@"vio_noresult"]];
    
    // 若从推送进入,则直接进行查询
    if ( self.info != nil) {
        CarTypeString = [self.info objectForKey:@"cartype"];
        [CarType setTitle:[types objectAtIndex:[CarTypeString intValue]-1] forState:UIControlStateNormal];
        CarNum.text = [self.info objectForKey:@"hphm"];
        ChassisNum.text = [self.info objectForKey:@"vin"];
        [self sendToServer:nil];
    }
}

- (void) checkBoxChanged:(M13Checkbox *) aCheckBox{
    if (aCheckBox == checkBox2 && aCheckBox.checkState==M13CheckboxStateChecked){
        [checkBox1 setCheckState:M13CheckboxStateChecked];
    }
    if (aCheckBox == checkBox1 && aCheckBox.checkState==M13CheckboxStateUnchecked){
        [checkBox2 setCheckState:M13CheckboxStateUnchecked];
    }
}

- (void) changeToUpperCase:(UITextField *) textField{
    textField.text = [textField.text uppercaseString];
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
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count - 2] animated:true];
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
        NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"0"];
        if (selectedIndex < 9) {
            [tmp appendString:[NSString stringWithFormat:@"%d", selectedIndex + 1]];
            CarTypeString = tmp;
        } else {
            CarTypeString = [[NSString stringWithFormat:@"%d", selectedIndex + 1] mutableCopy];
        }
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
    
    [stringpicker showActionSheetPicker];
}

- (void)cleanData
{
    [defaultback setHidden:NO];
    [result setHidden:YES];
    [resultline setHidden:YES];
    [resultline_shadow setHidden:YES];
    [no_result_image setHidden:YES];
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
    
    [result setHidden:YES];
    [resultline setHidden:YES];
    [resultline_shadow setHidden:YES];
    [no_result_image setHidden:YES];
    
    [[JDOJsonClient sharedClient] getPath:VIOLATION_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[(NSDictionary *)responseObject objectForKey:@"status"] isKindOfClass:[NSNumber class]]) {
            NSArray *datas = [[(NSDictionary *)responseObject objectForKey:@"data"] objectForKey:@"data"];
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
            [JDOCommonUtil showHintHUD:@"服务器错误，请稍后再试。" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDOCommonUtil showHintHUD:@"服务器错误，请稍后再试。" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
    }];
    
    [CarNum resignFirstResponder];
    [ChassisNum resignFirstResponder];
    
    // 从列表界面转过来的，不需要再进行保存和绑定
    if( sender == nil ) {
        return;
    }
    
    // 车牌号存在则不允许保存和绑定
    if (checkBox1.isChecked && [self readCarMessage]){
        for (int i = 0; i < carMessageArray.count; i++) {
            if ([[[carMessageArray objectAtIndex:i] objectForKey:@"hphm"] isEqualToString:CarNumString]) {
                [JDOCommonUtil showHintHUD:@"相同车牌号已存在，请先从列表中删除。" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
                return;
            }
        }
    }
    
    // 设置违章推送
    if (checkBox2.isChecked) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"JDO_Push_UserId"];
        if (userId == nil) {
            [self dealWithBindError];
        }else{
            [params setObject:userId forKey:@"userid"];
            [[JDOJsonClient sharedClient] getPath:BINDVIOLATIONINFO_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id status = [(NSDictionary *)responseObject objectForKey:@"status"];
                if ([status isKindOfClass:[NSNumber class]]) {
                    int _status = [status intValue];
                    if (_status == 1) { //绑定成功
                        if (checkBox1.isChecked) {
                            [self saveCarMessage:true];
                        }
                    }else if(_status == 0){
                        [self dealWithBindError];
                    }
                } else if([status isKindOfClass:[NSString class]]){
                    if ([status isEqualToString:@"wrongparam"]) {
                        [self dealWithBindError];
                    }else if([status isEqualToString:@"exist"]){
                        NSLog(@"已经存在绑定信息:%@",status);
                        // 服务器已经存在绑定信息,但有可能ispush的状态与当前客户端checkbox2的状态不同，在这里执行一遍更新
                        NSDictionary *_param = [NSDictionary dictionaryWithObjectsAndKeys:CarNumString,@"hphm",userId,@"userid",[NSNumber numberWithBool:true],@"ispush", nil];
                        [[JDOJsonClient sharedClient] getPath:SETVIOPUSHPERMISSION_SERVICE parameters:_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            id status = [(NSDictionary *)responseObject objectForKey:@"status"];
                            if ([status isKindOfClass:[NSNumber class]]) {
//                                int _status = [status intValue];
//                                if (_status == 1) { //成功
                                    if (checkBox1.isChecked) {
                                        [self saveCarMessage:true];
                                    }
//                                }else if(_status == 0){
//                                    
//                                }
                            } else if([status isKindOfClass:[NSString class]]){
                                // 逻辑上不会返回string类型
                            }
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [self dealWithBindError];
                        }];
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self dealWithBindError];
            }];
        }
    }else{
        if (checkBox1.isChecked) {
            [self saveCarMessage:false];
        }
    }
}

- (void) dealWithBindError{
    [JDOCommonUtil showHintHUD:@"未能开启违章自动提醒，请稍后再试。" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
    [checkBox2 setCheckState:M13CheckboxStateUnchecked];
    if (checkBox1.isChecked) {
        [self saveCarMessage:false];
    }
}

- (void)saveCarMessage:(BOOL)isPush
{
    NSDictionary *carMessage = @{@"hphm":[CarNumString uppercaseString], @"cartype":CarTypeString, @"vin":ChassisNumString, @"cartypename":CarType.titleLabel.text,@"ispush":[NSNumber numberWithBool:isPush]};
    if (![self readCarMessage]) {
        carMessageArray = [[NSMutableArray alloc] init];
    }
    [carMessageArray addObject:carMessage];
    [NSKeyedArchiver archiveRootObject:carMessageArray toFile:JDOGetDocumentFilePath(@"CarMessage")];
    carMessageArray = nil;
}

- (BOOL) readCarMessage{
    carMessageArray = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetDocumentFilePath(@"CarMessage")];
    return (carMessageArray != nil);
}

- (BOOL)checkEmpty
{
    if (CarNumString.length != 7) {
        [JDOCommonUtil showHintHUD:@"请输入正确的车牌号" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return YES;
    }
    if (ChassisNumString.length != 4){
        [JDOCommonUtil showHintHUD:@"请输入车架号后四位" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
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

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (resultArray.count > 0) {
        NSString *cellIdentifier = @"ViolationTableCell";
        
        JDOViolationTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[JDOViolationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *temp = [resultArray objectAtIndex:indexPath.row];
        if ((App_Height > 480)&&(resultArray.count == 1)) {
            cell.iphone5Style = 85.0;
        } else {
            cell.iphone5Style = 0.0;
        }
        [cell setData:temp];
        if (indexPath.row == resultArray.count - 1) {
            [cell setSeparator:[UIImage imageNamed:@"vio_line_wavy"]];
        } else {
            [cell setSeparator:nil];
        }
        
        return cell;
    }
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return resultArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end

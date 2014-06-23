//
//  JDONewsDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPartyJoinController.h"
#import "UIDevice+IdentifierAddition.h"

@interface JDOPartyJoinController ()

@end

@implementation JDOPartyJoinController

NSMutableArray *reg_views;
NSArray *reg_fields;

- (id)initWithPartyJoin:(NSDictionary *)partyJoin{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.partyJoin = partyJoin;
    }
    return self;
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"我要参与"];
}

- (void) onBackBtnClick{
    for (UIView *view in reg_views) {
        [view resignFirstResponder];
    }
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
//    UILabel *appidLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 50.0, 280.0, 40.0)];
//    [appidLabel setTextColor:[UIColor redColor]];
//    [appidLabel setFont:[UIFont systemFontOfSize:12.0]];
//    [appidLabel setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview:appidLabel];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appID"]) {
//        [appidLabel setText:[NSString stringWithFormat:@"您的AppID为：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appID"]]];
//    } else {
//        NSDictionary *params = @{@"deviceid":[[UIDevice currentDevice] uniqueDeviceIdentifier]};
//        JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
//        [httpclient getPath:APPID_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
//            id statusvalue = [json objectForKey:@"status"];
//            if ([statusvalue isKindOfClass:[NSString class]]) {
//                NSString *statusString = [json objectForKey:@"status"];
//                if ([statusString isEqualToString:@"exist"]) {
//                    NSDictionary *data = [json objectForKey:@"data"];
//                    NSString *appID = [data objectForKey:@"code"];
//                    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:@"appID"];
//                    [appidLabel setText:[NSString stringWithFormat:@"您的AppID为：%@",appID]];
//                }
//            } else if ([statusvalue isKindOfClass:[NSNumber class]]) {
//                int statusInt = [[json objectForKey:@"status"] intValue];
//                if (statusInt == 1) {
//                    NSDictionary *data = [json objectForKey:@"data"];
//                    NSString *appID = [data objectForKey:@"code"];
//                    [[NSUserDefaults standardUserDefaults] setObject:appID forKey:@"appID"];
//                    [appidLabel setText:[NSString stringWithFormat:@"您的AppID为：%@",appID]];
//                } else {
//                    [appidLabel setText:@"无法获取您的AppID"];
//                }
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [appidLabel setText:@"无法获取您的AppID"];
//        }];
//    }
    
    reg_views = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    int y = Is_iOS7?70:50;
    reg_fields = (NSArray *)[self.partyJoin objectForKey:@"reg_fields"];
    for (NSDictionary *reg_field in reg_fields) {
        if ([(NSString *)[reg_field objectForKey:@"active_required"] isEqualToString:@"1"]) {//必填项，加星号
            UILabel *need = [[UILabel alloc] initWithFrame:CGRectMake(20, y+8, 10, 10)];
            need.text = @"*";
            need.textColor = [UIColor redColor];
            need.backgroundColor = [UIColor clearColor];
            [need sizeToFit];
            [self.view addSubview:need];
        }
        if ([reg_field objectForKey:@"active_field_info"]) {//提交项名称
            UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(35, y, 90, 30)];
            info.text = [reg_field objectForKey:@"active_field_info"];
            info.backgroundColor = [UIColor clearColor];
            [self.view addSubview:info];
        }
        NSString *field_type = (NSString *)[reg_field objectForKey:@"active_field_type"];
        if ([field_type isEqualToString:@"text"]) {//文本
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, y, 180, 30)];
            [textField setBorderStyle:UITextBorderStyleNone];
            textField.background = [UIImage imageNamed:@"vio_textfield_back.png"];
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.returnKeyType = UIReturnKeyDone;
            textField.delegate = self;
            if ([[reg_field objectForKey:@"active_data_type"] isEqualToString:@"int"]) {//数据类型
                [textField setKeyboardType:UIKeyboardTypeNumberPad];
            } else if ([[reg_field objectForKey:@"active_data_type"] isEqualToString:@"phone"]) {
                [textField setKeyboardType:UIKeyboardTypePhonePad];
            } else if ([[reg_field objectForKey:@"active_data_type"] isEqualToString:@"idcard"]) {
                [textField setKeyboardType:UIKeyboardTypeNamePhonePad];
            } else if ([[reg_field objectForKey:@"active_data_type"] isEqualToString:@"email"]) {
                [textField setKeyboardType:UIKeyboardTypeEmailAddress];
            }
            [reg_views addObject:textField];
            [self.view addSubview:textField];
            y = CGRectGetMaxY(textField.frame)+5;
        } else if ([field_type isEqualToString:@"textarea"]) {//长文本
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(120, y, 180, 120)];
            [textField setBorderStyle:UITextBorderStyleNone];
            textField.background = [UIImage imageNamed:@"vio_textfield_back.png"];
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.returnKeyType = UIReturnKeyDone;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
            textField.delegate = self;
            [reg_views addObject:textField];
            [self.view addSubview:textField];
            y = CGRectGetMaxY(textField.frame)+5;
        } else if ([field_type isEqualToString:@"radio"]) {//单选框
            
        } else if ([field_type isEqualToString:@"select"]) {//下拉框
            
        } else if ([field_type isEqualToString:@"checkbox"]) {//复选框
            
        }
    }
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(20, y, 280, 50)];
    NSString *btnBackground = Is_iOS7?@"wide_btn~iOS7":@"wide_btn";
    [submit setBackgroundImage:[UIImage imageNamed:btnBackground] forState:UIControlStateNormal];
    [submit setTitle:@"提 交" forState:UIControlStateNormal];
    submit.userInteractionEnabled = YES;
    [submit setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submit.titleLabel setShadowOffset:Is_iOS7?CGSizeMake(0, 0):CGSizeMake(0, -1)];
    [submit addTarget:self action:@selector(submitClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submit];
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    for (UIView *view in reg_views) {
        [view resignFirstResponder];
    }
}

-(void) submitClicked {
    for (UIView *view in reg_views) {
        [view resignFirstResponder];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[self.partyJoin objectForKey:@"id"] forKey:@"aid"];
    for (int i=0;i<[reg_fields count];i++) {
        if ([reg_views[i] isKindOfClass:[UITextField class]]) {
            if(((UITextField *)reg_views[i]).text && ![((UITextField *)reg_views[i]).text isEqualToString:@""]) {
//                NSData *tempData = [[[@"\"" stringByAppendingString:[reg_fields[i] objectForKey:@"active_field_name"] ] stringByAppendingString:@"\""] dataUsingEncoding:NSUTF8StringEncoding];
//                NSString *returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                                       mutabilityOption:NSPropertyListImmutable
//                                                                                 format:NULL
//                                                                       errorDescription:NULL];
                if ([[reg_fields[i] objectForKey:@"active_data_type"] isEqualToString:@"phone"]) {
                    if (![self isMobileNumber:((UITextField *)reg_views[i]).text]) {
                        [JDOCommonUtil showHintHUD:@"电话格式错误" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
                        return;
                    }
                } else if ([[reg_fields[i] objectForKey:@"active_data_type"] isEqualToString:@"email"]) {
                    if (![self validateEmail:((UITextField *)reg_views[i]).text]) {
                        [JDOCommonUtil showHintHUD:@"邮箱格式错误" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
                        return;
                    }
                }
                
                [params setValue:((UITextField *)reg_views[i]).text forKey:[reg_fields[i] objectForKey:@"active_field_name"]];
            } else {
                NSString *str = [[NSString alloc] init];
                str = [[[str stringByAppendingString:@"请输入"] stringByAppendingString:[(NSDictionary *)reg_fields[i] objectForKey:@"active_field_info"]] stringByAppendingString:@"!"];
                [JDOCommonUtil showHintHUD:str inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
                return;
            }
        }
    }
    
    JDOHttpClient *httpclient = [JDOHttpClient sharedClient];
    
    [httpclient getPath:ACTIVEREG_SERVICE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [(NSData *)responseObject objectFromJSONData];
        id jsonvalue = [json objectForKey:@"status"];
        if ([jsonvalue isKindOfClass:[NSNumber class]]) {
            int status = [[json objectForKey:@"status"] intValue];
            if (status == 1) {
                [JDOCommonUtil showSuccessHUD:@"提交成功" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
            } else {
                [JDOCommonUtil showHintHUD:@"提交失败" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
            }
        } else {
            [JDOCommonUtil showHintHUD:@"提交失败" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorString = [JDOCommonUtil formatErrorWithOperation:operation error:error];
        [JDOCommonUtil showHintHUD:@"提交失败" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        NSLog(@"status:%@", errorString);
    }];
}

- (BOOL) validateEmail: (NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end

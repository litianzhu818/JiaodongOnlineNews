//
//  JDOLoginController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-9-3.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOLoginController.h"
#import "JDORegisterController.h"
#import "JDOUserTextField.h"
#import "JDORightViewController.h"

@interface JDOLoginController () <UITextFieldDelegate>

@property (nonatomic,strong) UIButton *loginBtn;
@property (nonatomic,strong) UIButton *registBtn;
@property (nonatomic,strong) JDOUserTextField *userName;
@property (nonatomic,strong) JDOUserTextField *password;

@end

@implementation JDOLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView{
    [super loadView];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height) ];
    backgroundView.image = [UIImage imageNamed:@"menu_background_right"];
    backgroundView.userInteractionEnabled = true;
    [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)]];
    [self.view addSubview:backgroundView];
    
    _userName = [[JDOUserTextField alloc] initWithFrame:CGRectMake(30,(Is_iOS7?64:44)+30, 320-30-30, 40)];
    _userName.background = [UIImage imageNamed:@"user_input_border"];
    _userName.placeholder = @"用户名/手机号";
    _userName.placeHolderColor = [UIColor lightGrayColor];
    _userName.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_account_icon"]];
    _userName.leftViewMode = UITextFieldViewModeAlways;
    _userName.textColor = [UIColor whiteColor];
    _userName.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_userName];
    
    _password = [[JDOUserTextField alloc] initWithFrame:CGRectMake(30,CGRectGetMaxY(_userName.frame)+10, 320-30-30, 40)];
    _password.background = [UIImage imageNamed:@"user_input_border"];
    _password.placeholder = @"密码";
    _password.placeHolderColor = [UIColor lightGrayColor];
    _password.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_password_icon"]];
    _password.leftViewMode = UITextFieldViewModeAlways;
    _password.textColor = [UIColor whiteColor];
    _password.font = [UIFont systemFontOfSize:16];
    _password.secureTextEntry = true;
    [self.view addSubview:_password];
    
    UIButton *forgetPwd = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPwd.frame = CGRectMake(0, 0, 70, 36);
    [forgetPwd setBackgroundImage:[UIImage imageNamed:@"user_validate_code"] forState:UIControlStateNormal];
    [forgetPwd setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetPwd setTitleColor:[UIColor colorWithHex:@"323232"] forState:UIControlStateNormal];
    forgetPwd.titleLabel.font = [UIFont systemFontOfSize:14];
    [forgetPwd addTarget:self action:@selector(findPassword:) forControlEvents:UIControlEventTouchUpInside];
    _password.rightView = forgetPwd;
    _password.rightViewPadding = 2;
    _password.rightViewMode = UITextFieldViewModeAlways;
    
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(30, CGRectGetMaxY(_password.frame)+30, (320-30-30-10)/2, 40);
    [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"user_blue_btn"] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(doLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_loginBtn setSelected:true];
    [self.view addSubview:_loginBtn];
    
    _registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _registBtn.frame = CGRectMake(30+CGRectGetWidth(_loginBtn.bounds)+10, CGRectGetMaxY(_password.frame)+30, CGRectGetWidth(_loginBtn.bounds),40);
    [_registBtn setTitle:@"注 册" forState:UIControlStateNormal];
    [_registBtn setTitleColor:[UIColor colorWithHex:@"6e6e6e"] forState:UIControlStateNormal];
    _registBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_registBtn setBackgroundImage:[UIImage imageNamed:@"user_white_btn"] forState:UIControlStateNormal];
    [_registBtn addTarget:self action:@selector(goToRegist:) forControlEvents:UIControlEventTouchUpInside];
    [_registBtn setSelected:false];
    [self.view addSubview:_registBtn];
}

- (void)findPassword:(UIButton *)btn{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    if (JDOIsEmptyString(_userName.text)) {
        [JDOCommonUtil showHintHUD:@"请输入您忘记密码的用户名或手机号" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您的密码将被重置" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == alertView.cancelButtonIndex){
        
    }else{
        // 发送密码重置请求
        [JDOCommonUtil showSuccessHUD:@"重置密码短信已经发送到你绑定的手机号码，请查收" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
    }
}

- (void)hideKeyboard:(UITapGestureRecognizer *)tap{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
}

- (void)goToRegist:(UIButton *)btn{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    JDORegisterController *registerController = [[JDORegisterController alloc] init];
    [self.stackContainer pushViewController:registerController direction:1];
}

- (void)doLogin:(UIButton *)btn{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    if (JDOIsEmptyString(_userName.text)) {
        [JDOCommonUtil showHintHUD:@"请输入用户名" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return;
    }
    if (JDOIsEmptyString(_password.text)) {
        [JDOCommonUtil showHintHUD:@"请输入密码" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return;
    }
    // 验证用户名和密码是否匹配
    if (true /*匹配*/) {  // 返回用户名，头像地址
        [[NSUserDefaults standardUserDefaults] setObject:@"用户名" forKey:@"JDO_User_Name"];
        if (false /* 有头像地址 */) {
            [[NSUserDefaults standardUserDefaults] setObject:@"Uploads/20140901/5403ceabb8142.jpg" forKey:@"JDO_User_Avatar"];
        }else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JDO_User_Avatar"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [(JDORightViewController *)self.stackContainer refreshUserInfo];
        [self.stackContainer popViewController:1];
    }else{
        [JDOCommonUtil showHintHUD:@"用户名与密码不匹配" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
    }
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setBackground:nil];
    [self.navigationView setTitle:@"用户登录"];
}

- (void)onBackBtnClick{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    [self.stackContainer popViewController:1];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [_userName becomeFirstResponder];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void) dealloc{

}

@end

//
//  JDORegisterController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-9-4.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDORegisterController.h"
#import "JDOUserTextField.h"

@interface JDORegisterController () <UITextFieldDelegate>

@property (nonatomic,strong) UIButton *existAccountBtn;
@property (nonatomic,strong) UIButton *createAccountBtn;
@property (nonatomic,strong) JDOUserTextField *userName;
@property (nonatomic,strong) JDOUserTextField *password;

@end

@implementation JDORegisterController

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
    [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)]];
    [self.view addSubview:backgroundView];
    
    _existAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _existAccountBtn.frame = CGRectMake(30, (Is_iOS7?64:44)+20, (320-30-30-10)/2, 40);
    [_existAccountBtn setTitle:@"已有17路论坛账号" forState:UIControlStateNormal];
    _existAccountBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_existAccountBtn setBackgroundImage:[UIImage imageNamed:@"user_type_selected"] forState:UIControlStateSelected];
    [_existAccountBtn setBackgroundImage:[UIImage imageNamed:@"user_type_unselected"] forState:UIControlStateNormal];
    [_existAccountBtn addTarget:self action:@selector(changeBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_existAccountBtn];
    
    _createAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _createAccountBtn.frame = CGRectMake(30+CGRectGetWidth(_existAccountBtn.bounds)+10, (Is_iOS7?64:44)+20, CGRectGetWidth(_existAccountBtn.bounds),40);
    [_createAccountBtn setTitle:@"创建新账号" forState:UIControlStateNormal];
    _createAccountBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_createAccountBtn setBackgroundImage:[UIImage imageNamed:@"user_type_selected"] forState:UIControlStateSelected];
    [_createAccountBtn setBackgroundImage:[UIImage imageNamed:@"user_type_unselected"] forState:UIControlStateNormal];
    [_createAccountBtn addTarget:self action:@selector(changeBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_createAccountBtn];
    
    [_createAccountBtn setSelected:false];
    [self changeBtnState:_createAccountBtn];
    
    _userName = [[JDOUserTextField alloc] initWithFrame:CGRectMake(30,CGRectGetMaxY(_existAccountBtn.frame)+20, 320-30-30, 40)];
    _userName.background = [UIImage imageNamed:@"user_input_border"];
    _userName.placeholder = @"用户名";
    _userName.placeHolderColor = [UIColor lightGrayColor];
    _userName.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_account_icon"]];
    _userName.leftViewMode = UITextFieldViewModeAlways;
    _userName.rightViewMode = UITextFieldViewModeAlways;
    _userName.textColor = [UIColor whiteColor];
    _userName.font = [UIFont systemFontOfSize:16];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userNameChanged:) name:UITextFieldTextDidChangeNotification object:_userName];
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
    
//    UIButton *confirmCode = [UIButton buttonWithType:UIButtonTypeCustom];
//    confirmCode.frame = CGRectMake(0, 0, 70, 36);
//    [confirmCode setBackgroundImage:[UIImage imageNamed:@"user_validate_code"] forState:UIControlStateNormal];
//    [confirmCode setTitle:@"获取验证码" forState:UIControlStateNormal];
//    [confirmCode setTitleColor:[UIColor colorWithHex:@"323232"] forState:UIControlStateNormal];
//    confirmCode.titleLabel.font = [UIFont systemFontOfSize:13];
//    [confirmCode addTarget:self action:@selector(sendConfirmCode:) forControlEvents:UIControlEventTouchUpInside];
//    _password.rightView = confirmCode;
//    _password.rightViewPadding = 2;
//    _password.rightViewMode = UITextFieldViewModeAlways;
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.frame = CGRectMake(30, CGRectGetMaxY(_password.frame)+20, 320-30-30,40);
    [completeBtn setTitle:@"确 认" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    completeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [completeBtn setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [completeBtn.titleLabel setShadowOffset:Is_iOS7?CGSizeMake(0, 0):CGSizeMake(0, -1)];
    [completeBtn setBackgroundImage:[UIImage imageNamed:@"user_complete_btn"] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(goToNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBtn];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)tap{
    [_userName resignFirstResponder];
    [_password resignFirstResponder];
}

- (void)sendConfirmCode:(UIButton *)btn{
    
}

- (void)userNameChanged:(NSNotification *)noti{
    if (JDOIsEmptyString(_userName.text) || _existAccountBtn.selected) {
        _userName.rightView = nil;
        return;
    }
    // 测试创建新用户名是否重复
    if([_userName.text isEqualToString:@"aa"]){
        _userName.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_account_exist"]];
    }else{
        _userName.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_account_free"]];
    }
}

- (void)goToNext:(UIButton *)btn{
    if (JDOIsEmptyString(_userName.text)) {
        [JDOCommonUtil showHintHUD:@"用户名未输入" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return;
    }
    if (JDOIsEmptyString(_password.text)) {
        [JDOCommonUtil showHintHUD:@"密码未输入" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        return;
    }
    if (_existAccountBtn.selected) {    // 校验已经存在的用户名密码是否正确
        if(true /*用户名不存在*/){
            [JDOCommonUtil showHintHUD:@"用户名不存在" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        }else if(true /*用户名密码不匹配*/){
            [JDOCommonUtil showHintHUD:@"用户名与密码不匹配" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        }else if(true /*用户名已注册过*/){
            [JDOCommonUtil showHintHUD:@"用户名已注册" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        }else{
            
        }
    }else if(_createAccountBtn.selected){
        if(true /*用户名已经注册过*/){
            [JDOCommonUtil showHintHUD:@"用户名已注册" inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
        }else{  // 进入绑定手机号页面
            
        }
    }
}

- (void)changeBtnState:(UIButton *)btn{
    if (!btn.isSelected) {
        _existAccountBtn.selected = false;
        _createAccountBtn.selected = false;
        [_existAccountBtn setTitleColor:[UIColor colorWithHex:@"6e6e6e"] forState:UIControlStateNormal];
        [_createAccountBtn setTitleColor:[UIColor colorWithHex:@"6e6e6e"] forState:UIControlStateNormal];
        btn.selected = true;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setBackground:nil];
    [self.navigationView setTitle:@"注册胶东在线客户端"];
}

- (void) onBackBtnClick{
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_userName];
}

@end

//
//  JDOUserController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-9-4.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOUserController.h"
#import "RSKImageCropper.h"
#import "JDORightViewController.h"
#import "NIPaths.h"
#import "SSLineView.h"
#import "CustomIOS7AlertView.h"
#import "JDOUserTextField.h"

#define Font_Color @"b4b4b4"
#define Score_Width 50
#define Complete_Width 50

@interface JDOUserController () <RSKImageCropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@end

@implementation JDOUserController{
    
    UILabel *userLabel;
    UIImageView *avatar;
    CustomIOS7AlertView *phoneAlertView;
    CustomIOS7AlertView *pwdAlertView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height) ];
    backgroundView.image = [UIImage imageNamed:@"menu_background_right"];
    [self.view addSubview:backgroundView];
    
    float top = Is_iOS7?20:0;
    avatar = [[UIImageView alloc] initWithFrame:CGRectMake((320-User_Avatar_Size)/2, top+20, User_Avatar_Size, User_Avatar_Size)];
    avatar.userInteractionEnabled = true;
    avatar.backgroundColor = [UIColor clearColor];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = User_Avatar_Size / 2;
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAvatar:)]];
//    NSString *avatarUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"JDO_User_Avatar"];
//    if (avatarUrl) {
//        [avatar setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:avatarUrl]] success:^(UIImage *image, BOOL cached) {
//            
//        } failure:^(NSError *error) {
//            
//        }];
//    }else{
//        avatar.image = [UIImage imageNamed:@"menu_avatar"];
//    }
    //===============
    NSFileManager * fm = [NSFileManager defaultManager];
    NSData *imgData = [fm contentsAtPath:NIPathForDocumentsResource(@"demo_avatar")];
    if(imgData){
        UIImage *demoImage = [UIImage imageWithData:imgData];
        avatar.image = demoImage;
    }else{
        avatar.image = [UIImage imageNamed:@"menu_avatar"];
    }
    //===============
    
    [self.view addSubview:avatar];
    
    userLabel = [[UILabel alloc] init];
    userLabel.font = [UIFont systemFontOfSize:18.0f];
    userLabel.textColor = [UIColor whiteColor];
    userLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"JDO_User_Name"];
    [userLabel sizeToFit];
    userLabel.frame = CGRectMake((320-userLabel.bounds.size.width)/2, top+100, CGRectGetWidth(userLabel.bounds), CGRectGetHeight(userLabel.bounds));
    [self.view addSubview:userLabel];
    
    
    // 个人信息
    UIImageView *userSectionIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_account_icon"]];
    userSectionIcon.frame = CGRectMake(30, 160, 19, 19);
    [self.view addSubview:userSectionIcon];
    
    UILabel *userSectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userSectionIcon.frame)+10, CGRectGetMinY(userSectionIcon.frame), 160, 19)];
    userSectionTitle.font = [UIFont systemFontOfSize:18];
    userSectionTitle.textColor = [UIColor colorWithHex:Font_Color];
    userSectionTitle.text = @"个人信息";
    [self.view addSubview:userSectionTitle];
    
    SSLineView *line1 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(userSectionIcon.frame)+5, 320-30-30, 1)];
    line1.lineColor = [UIColor colorWithHex:Font_Color];
    [self.view addSubview:line1];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(line1.frame)+5, 70, 25)];
    phoneLabel.font = [UIFont systemFontOfSize:16];
    phoneLabel.textColor = [UIColor colorWithHex:Font_Color];
    phoneLabel.text = @"手机号:";
    [self.view addSubview:phoneLabel];
    
    UILabel *phoneContent = [[UILabel alloc] initWithFrame:CGRectMake(30+70, CGRectGetMaxY(line1.frame)+5, 130, 25)];
    phoneContent.font = [UIFont systemFontOfSize:16];
    phoneContent.textColor = [UIColor colorWithHex:Font_Color];
    phoneContent.text = @"18612345678";
    [self.view addSubview:phoneContent];
    
    UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneBtn.frame = CGRectMake(320-30-15, CGRectGetMaxY(line1.frame)+10, 15, 15);
    [phoneBtn setBackgroundColor:[UIColor clearColor]];
    [phoneBtn setBackgroundImage:[UIImage imageNamed:@"user_edit_btn"] forState:UIControlStateNormal];
    [phoneBtn addTarget:self action:@selector(changePhone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phoneBtn];
    
    SSLineView *line2 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(phoneLabel.frame)+5, 320-30-30, 1)];
    line2.lineColor = [UIColor colorWithHex:Font_Color];
    [self.view addSubview:line2];
    
    UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(line2.frame)+5, 70, 25)];
    pwdLabel.font = [UIFont systemFontOfSize:16];
    pwdLabel.textColor = [UIColor colorWithHex:Font_Color];
    pwdLabel.text = @"密   码:";
    [self.view addSubview:pwdLabel];
    
    UILabel *pwdContent = [[UILabel alloc] initWithFrame:CGRectMake(30+70, CGRectGetMaxY(line2.frame)+5, 130, 25)];
    pwdContent.font = [UIFont systemFontOfSize:16];
    pwdContent.textColor = [UIColor colorWithHex:Font_Color];
    pwdContent.text = @"******";
    [self.view addSubview:pwdContent];
    
    UIButton *pwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pwdBtn.frame = CGRectMake(320-30-15, CGRectGetMaxY(line2.frame)+10, 15, 15);
    [pwdBtn setBackgroundColor:[UIColor clearColor]];
    [pwdBtn setBackgroundImage:[UIImage imageNamed:@"user_edit_btn"] forState:UIControlStateNormal];
    [pwdBtn addTarget:self action:@selector(changePassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pwdBtn];
    
    SSLineView *line3 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(pwdLabel.frame)+5, 320-30-30, 1)];
    line3.lineColor = [UIColor colorWithHex:Font_Color];
    [self.view addSubview:line3];
    
//    UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(line3.frame)+5, 70, 25)];
//    sexLabel.font = [UIFont systemFontOfSize:16];
//    sexLabel.textColor = [UIColor colorWithHex:Font_Color];
//    sexLabel.text = @"性 别:";
//    [scrollView addSubview:sexLabel];
//    
//    UILabel *sexContent = [[UILabel alloc] initWithFrame:CGRectMake(30+70, CGRectGetMaxY(line3.frame)+5, 130, 25)];
//    sexContent.font = [UIFont systemFontOfSize:16];
//    sexContent.textColor = [UIColor colorWithHex:Font_Color];
//    sexContent.text = @"男";
//    [scrollView addSubview:sexContent];
    
    // 每日任务
    UIImageView *missionSectionIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_today_mission"]];
    missionSectionIcon.frame = CGRectMake(30, CGRectGetMaxY(line3.frame)+20, 19, 19);
    [self.view addSubview:missionSectionIcon];
    
    UILabel *missionSectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(missionSectionIcon.frame)+10, CGRectGetMinY(missionSectionIcon.frame), 160, 19)];
    missionSectionTitle.font = [UIFont systemFontOfSize:18];
    missionSectionTitle.textColor = [UIColor colorWithHex:Font_Color];
    missionSectionTitle.text = @"今日任务";
    [self.view addSubview:missionSectionTitle];
    
    SSLineView *line4 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(missionSectionIcon.frame)+5, 320-30-30, 1)];
    line4.lineColor = [UIColor colorWithHex:Font_Color];
    [self.view addSubview:line4];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(line4.frame)+5, 320-30-30, App_Height-CGRectGetMaxY(line4.frame)-5-40-20/*下边距*/-10/*间距*/)];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quitBtn.frame = CGRectMake(30, CGRectGetMaxY(scrollView.frame)+10, 320-30-30, 40);
    [quitBtn setBackgroundColor:[UIColor colorWithHex:@"c80023"]];
    [quitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [quitBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quitBtn];
    
    float nextY = 0;
    float leftPadding = 0;
    NSArray *missionTitles = @[@"连续登录",@"分享新闻",@"发表评论",@"推荐用户",@"发布爆料",@"浏览广告"];
    NSArray *missionScores = @[@"+5分",@"+15分",@"+10分",@"+50分",@"+30分",@"+10分"];
    NSArray *missionStates = @[@(true),@(true),@(false),@(true),@(true),@(false)];
    
    for (int i=0; i<missionTitles.count; i++) {
        UILabel *missionLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, nextY, 150, 25)];
        missionLabel.font = [UIFont systemFontOfSize:16];
        missionLabel.textColor = [UIColor colorWithHex:Font_Color];
        missionLabel.text = missionTitles[i];
        [scrollView addSubview:missionLabel];
        
        UILabel *missionScore = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding+150, nextY, Score_Width, 25)];
        missionScore.font = [UIFont systemFontOfSize:16];
        missionScore.textColor = [UIColor colorWithHex:Font_Color];
        missionScore.text = missionScores[i];
        [scrollView addSubview:missionScore];
        
        UILabel *missionState = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding+150+Score_Width+10, nextY, Complete_Width, 25)];
        missionState.font = [UIFont systemFontOfSize:16];
        if ([missionStates[i] boolValue]) {
            missionState.textColor = [UIColor colorWithHex:Font_Color];
            missionState.text = @"已完成";
        }else{
            missionState.textColor = [UIColor colorWithHex:@"dc1914"];
            missionState.text = @"未完成";
        }
        [scrollView addSubview:missionState];
        
        SSLineView *separatorLine = [[SSLineView alloc] initWithFrame:CGRectMake(leftPadding, nextY+25+5, 320-30-30, 1)];
        separatorLine.lineColor = [UIColor colorWithHex:Font_Color];
        [scrollView addSubview:separatorLine];
        
        nextY = CGRectGetMaxY(separatorLine.frame)+5;
    }
    
    scrollView.contentSize = CGSizeMake(320-30-30, nextY);
    
}

- (void)changePhone:(UIButton *)btn{
    if(!phoneAlertView){
        phoneAlertView = [[CustomIOS7AlertView alloc] initWithParentView:SharedAppDelegate.window];
        phoneAlertView.delegate = self;
        phoneAlertView.background = @"user_alert_phone_bg";
        phoneAlertView.yMotion = 80;
        phoneAlertView.yMotionIPhone5 = 80;
        UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 280, Is_iPhone4Inch?145:105)];
        
        if (Is_iPhone4Inch) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 260, 25)];
            title.textAlignment = UITextAlignmentCenter;
            title.text = @"更改手机号";
            title.font = [UIFont boldSystemFontOfSize:18];
            title.backgroundColor = [UIColor clearColor];
            [containView addSubview:title];
        }
        
        JDOUserTextField *phoneNumTF = [[JDOUserTextField alloc] initWithFrame:CGRectMake(10,Is_iPhone4Inch?50:10, 260, 40)];
        phoneNumTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        phoneNumTF.background = [UIImage imageNamed:@"user_alert_input"];
//        phoneNumTF.secureTextEntry = YES;
        phoneNumTF.placeholder = @"手机号";
        phoneNumTF.keyboardType = UIKeyboardTypeNumberPad;
        phoneNumTF.font = [UIFont systemFontOfSize:16];
        phoneNumTF.tag = 1001;
        [containView addSubview:phoneNumTF];
        
        JDOUserTextField *codeNumTF = [[JDOUserTextField alloc] initWithFrame:CGRectMake(10,Is_iPhone4Inch?100:60, 260, 40)];
        codeNumTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeNumTF.background = [UIImage imageNamed:@"user_alert_code"];
        codeNumTF.placeholder = @"验证码";
        codeNumTF.keyboardType = UIKeyboardTypeNumberPad;
        codeNumTF.font = [UIFont systemFontOfSize:16];
        codeNumTF.tag = 1002;
        [containView addSubview:codeNumTF];
        
        UIButton *confirmCode = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmCode.frame = CGRectMake(0, 0, 70, 36);
        [confirmCode setBackgroundColor:[UIColor clearColor]];
        [confirmCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [confirmCode setTitleColor:[UIColor colorWithHex:@"323232"] forState:UIControlStateNormal];
        confirmCode.titleLabel.font = [UIFont systemFontOfSize:14];
        [confirmCode addTarget:self action:@selector(sendConfirmCode:) forControlEvents:UIControlEventTouchUpInside];
        codeNumTF.rightView = confirmCode;
        codeNumTF.rightViewPadding = 2;
        codeNumTF.rightViewMode = UITextFieldViewModeAlways;
        
        phoneAlertView.containerView = containView;
        phoneAlertView.buttonTitles = @[@"确认",@"取消"];
    }
    [phoneAlertView show];
}

- (void)changePassword:(UIButton *)btn{
    if(!pwdAlertView){
        pwdAlertView = [[CustomIOS7AlertView alloc] initWithParentView:SharedAppDelegate.window];
        pwdAlertView.delegate = self;
        pwdAlertView.background = @"user_alert_pwd_bg";
        pwdAlertView.yMotion = 100;
        pwdAlertView.yMotionIPhone5 = 80;
        UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 280, Is_iPhone4Inch?195:155)];
        
        if (Is_iPhone4Inch) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 260, 25)];
            title.textAlignment = UITextAlignmentCenter;
            title.text = @"更改密码";
            title.font = [UIFont boldSystemFontOfSize:18];
            title.backgroundColor = [UIColor clearColor];
            [containView addSubview:title];
        }
        
        JDOUserTextField *currentPwd = [[JDOUserTextField alloc] initWithFrame:CGRectMake(10,Is_iPhone4Inch?50:10, 260, 40)];
        currentPwd.background = [UIImage imageNamed:@"user_alert_input"];
        currentPwd.secureTextEntry = YES;
        currentPwd.placeholder = @"当前密码";
        currentPwd.font = [UIFont systemFontOfSize:16];
        currentPwd.tag = 1001;
        [containView addSubview:currentPwd];
        
        JDOUserTextField *newPwd = [[JDOUserTextField alloc] initWithFrame:CGRectMake(10,Is_iPhone4Inch?100:60, 260, 40)];
        newPwd.background = [UIImage imageNamed:@"user_alert_input"];
        newPwd.secureTextEntry = YES;
        newPwd.placeholder = @"新密码";
        newPwd.font = [UIFont systemFontOfSize:16];
        newPwd.tag = 1002;
        [containView addSubview:newPwd];
        
        JDOUserTextField *confirmPwd = [[JDOUserTextField alloc] initWithFrame:CGRectMake(10,Is_iPhone4Inch?150:110, 260, 40)];
        confirmPwd.background = [UIImage imageNamed:@"user_alert_input"];
        confirmPwd.secureTextEntry = YES;
        confirmPwd.placeholder = @"确认新密码";
        confirmPwd.font = [UIFont systemFontOfSize:16];
        confirmPwd.tag = 1003;
        [containView addSubview:confirmPwd];
        
        pwdAlertView.containerView = containView;
        pwdAlertView.buttonTitles = @[@"确认",@"取消"];
    }
    [pwdAlertView show];
}

- (void)sendConfirmCode:(UIButton *)btn{
    
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){   // 取消
        [alertView close];
    }else{
        if (alertView == phoneAlertView) {
            
        }else if(alertView == pwdAlertView){
            
        }
//        NSString *secret = [(UITextField *)[alertView.containerView viewWithTag:Secret_Field_Tag] text];
//        if(JDOIsEmptyString(secret)){
//            return;
//        }
//        [(UITextField *)[alertView.containerView viewWithTag:Secret_Field_Tag] setText:nil];
//        [alertView close];
//        if ( [secret isEqualToString:secretQuestionModel.pwd] ) {   // 密码正确
//            JDOQuestionDetailController *detailController = [[JDOQuestionDetailController alloc] initWithQuestionModel:secretQuestionModel];
//            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
//            [centerController pushViewController:detailController animated:true];
//        }else{
//            [JDOCommonUtil showHintHUD:@"密码错误,请重新输入" inView:self];
//            [(UITextField *)[alertView.containerView viewWithTag:Secret_Field_Tag] setText:nil];
//        }
    }
}

- (void)logout:(UIButton *)btn{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JDO_User_Name"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JDO_User_Avatar"];
    // ==============
    [[NSFileManager defaultManager] removeItemAtPath:NIPathForDocumentsResource(@"demo_avatar") error:nil];
    // ==============
    [(JDORightViewController *)self.stackContainer refreshUserInfo];
    [self.stackContainer popViewController:1];
}

- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setBackground:nil];
//    [self.navigationView setTitle:@"用户信息"];
}

- (void)onBackBtnClick{
//    [_userName resignFirstResponder];
    [self.stackContainer popViewController:1];
}

- (void)changeAvatar:(UITapGestureRecognizer *)tap{
    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        sheet  = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
    }
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerControllerSourceType type ;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex == 0){
        type = UIImagePickerControllerSourceTypeCamera;
    }else if(([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && buttonIndex==1) || buttonIndex == 0){
        type = UIImagePickerControllerSourceTypePhotoLibrary;
    }else{
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = false;
    imagePickerController.sourceType = type;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self presentModalViewController:imagePickerController animated:true];
    }else{
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:true];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:false];
    }else{
        [self dismissViewControllerAnimated:false completion:NULL];
    }
    
    UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:photo];
    imageCropVC.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self presentModalViewController:imageCropVC animated:true];
    }else{
        [self presentViewController:imageCropVC animated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:true];
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:true];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage{
    UIImage *scaleImage;

    if (croppedImage.size.width > User_Avatar_Size) {   // 原始图片太大，剪切到头像的显示大小
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(User_Avatar_Size,User_Avatar_Size), NO, 0.0);
        [croppedImage drawInRect:CGRectMake(0, 0, User_Avatar_Size, User_Avatar_Size)];
        scaleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        scaleImage = croppedImage;
    }
    avatar.image = scaleImage;
    // 上传新头像
//    if (true) {
//        NSString *avatarUrl = @"Uploads/20140901/5403ceabb8142.jpg";
//        [[NSUserDefaults standardUserDefaults] setObject:avatarUrl forKey:@"JDO_User_Avatar"];
//        [(JDORightViewController *)self.stackContainer refreshUserInfo];
//    }
    
    //===============
    NSError *error;
    NSData *imageData = UIImagePNGRepresentation(scaleImage);
    [imageData writeToFile:NIPathForDocumentsResource(@"demo_avatar") options:NSDataWritingAtomic error:&error];
    if(error != nil){
        NSLog(@"保存图片错误:%@",error);
    }
    [(JDORightViewController *)self.stackContainer setAvatarImage:scaleImage];
    //===============
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<5.0) {
        [self dismissModalViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:true];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


@end

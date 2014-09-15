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

#define Font_Color @"b4b4b4"
#define Modify_Width 40
#define Score_Width 50
#define Complete_Width 50

@interface JDOUserController () <RSKImageCropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@end

@implementation JDOUserController{
    
    UILabel *userLabel;
    UIImageView *avatar;
    CustomIOS7AlertView *phoneAlertView;
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
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
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
    
    [scrollView addSubview:avatar];
    
    userLabel = [[UILabel alloc] init];
    userLabel.font = [UIFont systemFontOfSize:18.0f];
    userLabel.textColor = [UIColor whiteColor];
    userLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"JDO_User_Name"];
    [userLabel sizeToFit];
    userLabel.frame = CGRectMake((320-userLabel.bounds.size.width)/2, top+100, CGRectGetWidth(userLabel.bounds), CGRectGetHeight(userLabel.bounds));
    [scrollView addSubview:userLabel];
    
    
    // 个人信息
    UIImageView *userSectionIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_account_icon"]];
    userSectionIcon.frame = CGRectMake(30, 160, 19, 19);
    [scrollView addSubview:userSectionIcon];
    
    UILabel *userSectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userSectionIcon.frame)+10, CGRectGetMinY(userSectionIcon.frame), 160, 19)];
    userSectionTitle.font = [UIFont systemFontOfSize:18];
    userSectionTitle.textColor = [UIColor colorWithHex:Font_Color];
    userSectionTitle.text = @"个人信息";
    [scrollView addSubview:userSectionTitle];
    
    SSLineView *line1 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(userSectionIcon.frame)+5, 320-30-30, 1)];
    line1.lineColor = [UIColor colorWithHex:Font_Color];
    [scrollView addSubview:line1];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(line1.frame)+5, 70, 25)];
    phoneLabel.font = [UIFont systemFontOfSize:16];
    phoneLabel.textColor = [UIColor colorWithHex:Font_Color];
    phoneLabel.text = @"手机号:";
    [scrollView addSubview:phoneLabel];
    
    UILabel *phoneContent = [[UILabel alloc] initWithFrame:CGRectMake(30+70, CGRectGetMaxY(line1.frame)+5, 130, 25)];
    phoneContent.font = [UIFont systemFontOfSize:16];
    phoneContent.textColor = [UIColor colorWithHex:Font_Color];
    phoneContent.text = @"18612345678";
    [scrollView addSubview:phoneContent];
    
    UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phoneBtn.frame = CGRectMake(320-30-Modify_Width, CGRectGetMaxY(line1.frame)+5, Modify_Width, 25);
    [phoneBtn setBackgroundColor:[UIColor clearColor]];
    [phoneBtn setTitle:@"修改" forState:UIControlStateNormal];
    [phoneBtn setTitleColor:[UIColor colorWithHex:Font_Color] forState:UIControlStateNormal];
    [phoneBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [phoneBtn.titleLabel setTextAlignment:NSTextAlignmentRight];
    [phoneBtn addTarget:self action:@selector(changePhone:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:phoneBtn];
    
    SSLineView *line2 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(phoneLabel.frame)+5, 320-30-30, 1)];
    line2.lineColor = [UIColor colorWithHex:Font_Color];
    [scrollView addSubview:line2];
    
    UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(line2.frame)+5, 70, 25)];
    pwdLabel.font = [UIFont systemFontOfSize:16];
    pwdLabel.textColor = [UIColor colorWithHex:Font_Color];
    pwdLabel.text = @"密 码:";
    [scrollView addSubview:pwdLabel];
    
    UILabel *pwdContent = [[UILabel alloc] initWithFrame:CGRectMake(30+70, CGRectGetMaxY(line2.frame)+5, 130, 25)];
    pwdContent.font = [UIFont systemFontOfSize:16];
    pwdContent.textColor = [UIColor colorWithHex:Font_Color];
    pwdContent.text = @"******";
    [scrollView addSubview:pwdContent];
    
    UIButton *pwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pwdBtn.frame = CGRectMake(320-30-Modify_Width, CGRectGetMaxY(line2.frame)+5, Modify_Width, 25);
    [pwdBtn setBackgroundColor:[UIColor clearColor]];
    [pwdBtn setTitle:@"修改" forState:UIControlStateNormal];
    [pwdBtn setTitleColor:[UIColor colorWithHex:Font_Color] forState:UIControlStateNormal];
    [pwdBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [pwdBtn.titleLabel setTextAlignment:NSTextAlignmentRight];
    [scrollView addSubview:pwdBtn];
    
    SSLineView *line3 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(pwdLabel.frame)+5, 320-30-30, 1)];
    line3.lineColor = [UIColor colorWithHex:Font_Color];
    [scrollView addSubview:line3];
    
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
    [scrollView addSubview:missionSectionIcon];
    
    UILabel *missionSectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(missionSectionIcon.frame)+10, CGRectGetMinY(missionSectionIcon.frame), 160, 19)];
    missionSectionTitle.font = [UIFont systemFontOfSize:18];
    missionSectionTitle.textColor = [UIColor colorWithHex:Font_Color];
    missionSectionTitle.text = @"今日任务";
    [scrollView addSubview:missionSectionTitle];
    
    SSLineView *line4 = [[SSLineView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(missionSectionIcon.frame)+5, 320-30-30, 1)];
    line4.lineColor = [UIColor colorWithHex:Font_Color];
    [scrollView addSubview:line4];
    
    float nextY = CGRectGetMaxY(line4.frame)+5;
    NSArray *missionTitles = @[@"连续登录",@"分享新闻",@"发表评论",@"推荐用户",@"发布爆料",@"浏览广告"];
    NSArray *missionScores = @[@"+5分",@"+15分",@"+10分",@"+50分",@"+30分",@"+10分"];
    NSArray *missionStates = @[@(true),@(true),@(false),@(true),@(true),@(false)];
    
    for (int i=0; i<missionTitles.count; i++) {
        UILabel *missionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, nextY, 150, 25)];
        missionLabel.font = [UIFont systemFontOfSize:16];
        missionLabel.textColor = [UIColor colorWithHex:Font_Color];
        missionLabel.text = missionTitles[i];
        [scrollView addSubview:missionLabel];
        
        UILabel *missionScore = [[UILabel alloc] initWithFrame:CGRectMake(30+150, nextY, Score_Width, 25)];
        missionScore.font = [UIFont systemFontOfSize:16];
        missionScore.textColor = [UIColor colorWithHex:Font_Color];
        missionScore.text = missionScores[i];
        [scrollView addSubview:missionScore];
        
        UILabel *missionState = [[UILabel alloc] initWithFrame:CGRectMake(30+150+Score_Width+10, nextY, Complete_Width, 25)];
        missionState.font = [UIFont systemFontOfSize:16];
        if ([missionStates[i] boolValue]) {
            missionState.textColor = [UIColor colorWithHex:Font_Color];
            missionState.text = @"已完成";
        }else{
            missionState.textColor = [UIColor colorWithHex:@"dc1914"];
            missionState.text = @"未完成";
        }
        [scrollView addSubview:missionState];
        
        SSLineView *separatorLine = [[SSLineView alloc] initWithFrame:CGRectMake(30, nextY+25+5, 320-30-30, 1)];
        separatorLine.lineColor = [UIColor colorWithHex:Font_Color];
        [scrollView addSubview:separatorLine];
        
        nextY = CGRectGetMaxY(separatorLine.frame)+5;
    }
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quitBtn.frame = CGRectMake(30, nextY+15, 320-30-30, 40);
    [quitBtn setBackgroundColor:[UIColor colorWithHex:@"c80023"]];
    [quitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [quitBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:quitBtn];
    
    scrollView.contentSize = CGSizeMake(320, CGRectGetMaxY(quitBtn.frame)+20);
    
}

- (void)changePhone:(UIButton *)btn{
    if(!phoneAlertView){
        phoneAlertView = [[CustomIOS7AlertView alloc] initWithParentView:SharedAppDelegate.window];
//        _iOS7AlertView.delegate = self;
//        UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 260, 100)];
//        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 220, 20)];
//        title.textAlignment = UITextAlignmentCenter;
//        title.text = @"请输入查询密码";
//        title.backgroundColor = [UIColor clearColor];
//        [containView addSubview:title];
//        InsetsTextField *secretTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(20,45, 220, 35)];
//        secretTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        secretTextField.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
//        secretTextField.secureTextEntry = YES;
//        secretTextField.placeholder = @"6位数字";
//        secretTextField.keyboardType = UIKeyboardTypeNumberPad;
//        secretTextField.tag = Secret_Field_Tag;
//        [containView addSubview:secretTextField];
//        _iOS7AlertView.containerView = containView;
//        _iOS7AlertView.buttonTitles = @[@"取消",@"确认"];
    }
    [phoneAlertView show];
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

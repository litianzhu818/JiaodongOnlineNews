//
//  JDOShareController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-13.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOShareViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "JDOShareViewDelegate.h"
#import <TencentOpenAPI/QQApi.h>
#import "WXApi.h"
#import "SSTextView.h"
  
#define Image_Base_Tag 100
#define Btn_Base_Tag 200

@interface JDOShareViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet SSTextView *textView2;
@property (strong, nonatomic) IBOutlet UIButton *qqBtn;
@property (strong, nonatomic) IBOutlet UIButton *weixinBtn;
@property (strong, nonatomic) IBOutlet UIButton *friendsBtn;
@property (strong, nonatomic) IBOutlet UIView *reviewPanel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainWordLabel;

@end

@implementation JDOShareViewController{
    int shareTypes[4];
    NSArray *enableImageNames;
    NSArray *disableImageNames;
}

- (id) initWithModel:(id<JDOToolbarModel>) model{
    self = [super initWithNibName:nil  bundle:nil];
    if (self) {
        shareTypes[0] = ShareTypeSinaWeibo;
        shareTypes[1] = ShareTypeTencentWeibo;
        shareTypes[2] = ShareTypeQQSpace;
        shareTypes[3] = ShareTypeRenren;
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.imageView.layer.cornerRadius = 5.0;
    self.imageView.layer.masksToBounds = true;
    if( [self.model isKindOfClass:NSClassFromString(@"JDOImageModel")] ){
        // 图集的图片尺寸不可控,UIViewContentModeScaleToFill模式比例失调太严重
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
//    self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
//    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.imageView.layer.shadowOffset = CGSizeMake(2, 2);
//    self.imageView.layer.shadowOpacity = 0.8;
//    self.imageView.layer.shadowRadius = 1.8;
    
    // 图集中切换图片内容会跟着变,放到viewWillAppear中
//    [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:[self.model imageurl]]] placeholderImage:[UIImage imageNamed:@"news_image_placeholder.png"] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
//
//    } failure:^(NSError *error) {
//        
//    }];
    
    self.reviewPanel.layer.borderColor = [UIColor colorWithHex:@"969696"].CGColor;
    self.reviewPanel.layer.borderWidth = 1.0;
    self.textView2.layer.borderColor = [UIColor colorWithHex:@"969696"].CGColor;
    self.textView2.layer.borderWidth = 1.0;
    [self.textView2 setPlaceholder:@"说点什么吧"];
    self.textView2.backgroundColor = [UIColor colorWithHex:@"E6E6E6"];
    // 图集中切换图片内容会跟着变,放到viewWillAppear中
//    self.titleLabel.text = [self getShareTitleAndContent];
    self.titleLabel.textColor = [UIColor colorWithHex:@"505050"];
    self.remainWordLabel.textColor = [UIColor colorWithHex:@"969696"];
    
    [self.qqBtn setBackgroundImage:[UIImage imageNamed:@"QQ.png"] forState:UIControlStateNormal];
    [self.qqBtn setBackgroundImage:[UIImage imageNamed:@"QQ01.png"] forState:UIControlStateDisabled];
    [self.weixinBtn setBackgroundImage:[UIImage imageNamed:@"wx.png"] forState:UIControlStateNormal];
    [self.weixinBtn setBackgroundImage:[UIImage imageNamed:@"wx01.png"] forState:UIControlStateDisabled];
    [self.friendsBtn setBackgroundImage:[UIImage imageNamed:@"pyq.png"] forState:UIControlStateNormal];
    [self.friendsBtn setBackgroundImage:[UIImage imageNamed:@"pyq01.png"] forState:UIControlStateDisabled];
    
#warning 未安装qq或版本不符合的情况下可以提示安装
    if([QQApi isQQInstalled] && [QQApi isQQSupportApi]){
        [self.qqBtn setEnabled:true];
    }else{
        [self.qqBtn setEnabled:false];
    }
//    NSString *maxSupportApiVersion = [WXApi getWXAppSupportMaxApiVersion];
//    NSString *currentApiVersion = [WXApi getApiVersion];
    if([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi] ){
        [self.weixinBtn setEnabled:true];
        [self.friendsBtn setEnabled:true];
    }else{
        [self.weixinBtn setEnabled:false];
        [self.friendsBtn setEnabled:false];
    }
    
    disableImageNames = @[@"sina.png",@"tencent.png",@"qzone.png",@"renren.png"];
    enableImageNames = @[@"sina01.png",@"tencent01.png",@"qzone01.png",@"renren01.png"];
    for(int i=0; i<4 ;i++){
        UIButton *shareImage = (UIButton *)[self.mainView viewWithTag:Image_Base_Tag+i];
        [shareImage setBackgroundImage:[UIImage imageNamed:[enableImageNames objectAtIndex:i]] forState:UIControlStateNormal];
        [shareImage setBackgroundImage:[UIImage imageNamed:[disableImageNames objectAtIndex:i]] forState:UIControlStateDisabled];
        [shareImage addTarget:self action:@selector(getAuth:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *shareBtn = (UIButton *)[self.mainView viewWithTag:Btn_Base_Tag+i];
        [shareBtn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([ShareSDK hasAuthorizedWithType:shareTypes[i]] ){
            [shareImage setEnabled:false];
            [shareBtn setSelected:true];    // 默认选中有权限的
        }else{
            [shareImage setEnabled:true];
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.titleLabel.text = [self getShareTitleAndContent];
    [self.imageView setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:[self.model imageurl]]] placeholderImage:[UIImage imageNamed:@"news_image_placeholder.png"] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void) getAuth:(UIButton *)sender{
    int index = sender.tag - Image_Base_Tag;
    ShareType shareType = shareTypes[index];
    
    [ShareSDK authWithType:shareType options:JDOGetOauthOptions(nil) result:^(SSAuthState state, id<ICMErrorInfo> error) {
        if (state == SSAuthStateSuccess){
            [sender setEnabled:false];
        }else if(state == SSAuthStateFail){
            if ([error errorCode] != -103){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"绑定失败" message:[error errorDescription] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }];
}

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToParent)];
    [self.navigationView setTitle:@"分享"];
}

- (void) backToParent{
    JDOCenterViewController *centerController = (JDOCenterViewController *)self.navigationController;
    [centerController popToViewController:[centerController.viewControllers objectAtIndex:1] orientation:JDOTransitionToBottom animated:true];
}

- (void)viewDidUnload {
    [self setWeixinBtn:nil];
    [self setFriendsBtn:nil];
    [self setTextView2:nil];
    [self setImageView:nil];
    [self setReviewPanel:nil];
    [self setTitleLabel:nil];
    [self setRemainWordLabel:nil];
    [self setQqBtn:nil];
    [self setMainView:nil];
    [super viewDidUnload];
}

- (NSString *) getShareTitle{
    return [NSString stringWithFormat:@"//分享胶东在线新闻:「%@」",[self.model title]];
}

- (NSString *) getShareTitleAndContent{
    return [NSString stringWithFormat:@"//分享胶东在线新闻:「%@」%@",[self.model title],[self.model summary]];
}

- (IBAction)onQQClicked:(UIButton *)sender {
    [self sendShareMessage:ShareTypeQQ];
}

- (IBAction)onFriendsClicked:(UIButton *)sender {
    [self sendShareMessage:ShareTypeWeixiTimeline];
}

- (IBAction)onWeixinClicked:(UIButton *)sender {
    [self sendShareMessage:ShareTypeWeixiSession];
}

- (void) sendShareMessage:(ShareType) shareType{
    id<ISSContent> content = [ShareSDK content:[self.model summary]
                                defaultContent:nil
                                         image:[ShareSDK jpegImageWithImage:_imageView.image quality:1]
                                         title:[self.model title]
                                           url:[self.model tinyurl]
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK shareContent:content
                      type:shareType
               authOptions:JDOGetOauthOptions(nil)
             statusBarTips:YES
                    result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        if (state == SSPublishContentStateSuccess){
                            NSLog(@"success");
                        }else if (state == SSPublishContentStateFail){
                            NSLog(@"%d:%@",[error errorCode], [error errorDescription]);
                        }
                    }];
}

- (IBAction)onShareClicked:(UIButton *)sender {
    NSMutableArray *selectedClients = [NSMutableArray array];
    for(int i=0; i<4 ;i++){
        UIButton *shareBtn = (UIButton *)[self.mainView viewWithTag:Btn_Base_Tag+i];
        if(shareBtn.state & UIControlStateSelected){
            [selectedClients addObject:[NSNumber numberWithInteger:shareTypes[i]]];
        }
    }

    if ([selectedClients count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择需要分享的平台" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    id<ISSContent> publishContent = [ShareSDK content:[[_textView2.text stringByAppendingString:[self getShareTitleAndContent]] stringByAppendingFormat:@" %@",[self.model tinyurl]]
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:_imageView.image quality:1]
                                                title:[self.model title]
                                                  url:[self.model tinyurl]
                                          description:[self.model summary]
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK oneKeyShareContent:publishContent
                       shareList:selectedClients
                     authOptions:JDOGetOauthOptions(nil)
                   statusBarTips:YES
                          result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
#warning 根据状态alert提示分享成功,模态窗口,完成后自动返回上级页面
                              if(type == ShareTypeQQSpace){
#warning 未通过审核的应用没有发布图片的权限
                              }
                              if(error){
                                  NSLog(@"分享错误代码:%d",error.errorCode);
                              }
                          }];
    // 返回上级页面
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:1] orientation:JDOTransitionToBottom animated:true];
}

- (void)onBtnClicked:(UIButton *)sender {
    int index = sender.tag - Btn_Base_Tag;
    ShareType shareType = shareTypes[index];
    
    if([ShareSDK hasAuthorizedWithType:shareType] ){
        if (sender.state & UIControlStateSelected){
            [sender setSelected:false];
        }else{
            [sender setSelected:true];
        }
    }else{
        if (sender.state & UIControlStateSelected){
            [sender setSelected:false];
        }else{
            [ShareSDK authWithType:shareType options:JDOGetOauthOptions(nil) result:^(SSAuthState state, id<ICMErrorInfo> error) {
                if (state == SSPublishContentStateSuccess){
                    [sender setSelected:true];
                    UIButton *shareImage = (UIButton *)[self.mainView viewWithTag:Image_Base_Tag+index];
                    [shareImage setBackgroundImage:[UIImage imageNamed:[enableImageNames objectAtIndex:index]] forState:UIControlStateNormal];
                    [shareImage setEnabled:false];
                    
                }else if (state == SSPublishContentStateFail){
                    NSLog(@"%d:%@",[error errorCode], [error errorDescription]);
                }
            }];
        }
        
    }
    
}
@end

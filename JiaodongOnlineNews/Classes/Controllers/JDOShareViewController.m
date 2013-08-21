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
#define Label_Base_Tag 300

@interface JDOShareViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet SSTextView *textView2;
@property (strong, nonatomic) IBOutlet UIButton *qqBtn;
@property (strong, nonatomic) IBOutlet UIButton *weixinBtn;
@property (strong, nonatomic) IBOutlet UIButton *friendsBtn;
@property (strong, nonatomic) IBOutlet UIView *reviewPanel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainWordLabel;
@property (strong, nonatomic) IBOutlet UIButton *ShareBtn;

@end

@implementation JDOShareViewController{
    NSMutableArray *_shareTypeArray;
    NSArray *enableImageNames;
    NSArray *disableImageNames;
}

- (id) initWithModel:(id<JDOToolbarModel>) model{
    self = [super initWithNibName:nil  bundle:nil];
    if (self) {
        _shareTypeArray = [JDOCommonUtil getAuthList];
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.ShareBtn.titleLabel setShadowOffset:CGSizeMake(0, -1)];
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
    
    self.reviewPanel.layer.borderColor = [UIColor colorWithHex:Gray_Color_Type2].CGColor;
    self.reviewPanel.layer.borderWidth = 1.0;
    self.textView2.layer.borderColor = [UIColor colorWithHex:Gray_Color_Type2].CGColor;
    self.textView2.layer.borderWidth = 1.0;
    [self.textView2 setPlaceholder:@"说点什么吧"];
    self.textView2.backgroundColor = [UIColor colorWithHex:@"E6E6E6"];
    self.textView2.delegate = self;
    // 图集中切换图片内容会跟着变,放到viewWillAppear中
//    self.titleLabel.text = [self getShareTitleAndContent];
    self.titleLabel.textColor = [UIColor colorWithHex:Black_Color_Type2];
    self.remainWordLabel.textColor = [UIColor colorWithHex:Gray_Color_Type2];
    
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
    
    disableImageNames = @[@"sina.png",@"tencent.png",@"qzone.png",@"renren.png"];   // 亮色图标
    enableImageNames = @[@"sina01.png",@"tencent01.png",@"qzone01.png",@"renren01.png"];    //灰色图标
    for(int i=0; i<4 ;i++){
        UILabel *shareLabel = (UILabel *)[self.mainView viewWithTag:Label_Base_Tag+i];
        
        UIButton *shareImage = (UIButton *)[self.mainView viewWithTag:Image_Base_Tag+i];
        [shareImage setBackgroundImage:[UIImage imageNamed:[enableImageNames objectAtIndex:i]] forState:UIControlStateNormal];
        [shareImage setBackgroundImage:[UIImage imageNamed:[disableImageNames objectAtIndex:i]] forState:UIControlStateDisabled];
        [shareImage addTarget:self action:@selector(getAuth:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *shareBtn = (UIButton *)[self.mainView viewWithTag:Btn_Base_Tag+i];
        [shareBtn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        /*
        if (i%2 == 0) {
            [shareImage setFrame:CGRectMake(10 + 160*i, self.textView2.bottom + 10, shareImage.frame.size.width, shareImage.frame.size.height)];
            [shareLabel setFrame:CGRectMake(shareImage.right + 12, shareImage.top + 7, shareLabel.frame.size.width, shareLabel.frame.size.height)];
            [shareBtn setFrame:CGRectMake(shareLabel.right + 10, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)]
        } else {
            
        }
        */
        NSDictionary *item = [_shareTypeArray objectAtIndex:i];
        if([ShareSDK hasAuthorizedWithType:[[item objectForKey:@"type"] intValue] ] ){
            [shareImage setEnabled:false];  // 有授权时不能再次点击取消授权
            [shareBtn setSelected:[[item objectForKey:@"selected"] boolValue]];    
        }else{
            [shareImage setEnabled:true];
            [shareBtn setSelected:false];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.titleLabel.text = [self getShareTitleAndContent];
    int remaind = 130 - [_titleLabel.text length];
    self.remainWordLabel.text = [NSString stringWithFormat:@"还可以输入%d字",remaind];
    NSURL *url;
    if ([[self.model imageurl] hasPrefix:SERVER_RESOURCE_URL]) {
        url = [NSURL URLWithString:[self.model imageurl]];
    } else {
        url = [NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:[self.model imageurl]]];
    }
    [self.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"news_image_placeholder.png"] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void) getAuth:(UIButton *)imageBtn{
    int index = imageBtn.tag - Image_Base_Tag;
    UIButton *selectBtn = (UIButton *)[self.mainView viewWithTag:Btn_Base_Tag + index];
    NSMutableDictionary *item = [_shareTypeArray objectAtIndex:index];
    
    [ShareSDK getUserInfoWithType:[[item objectForKey:@"type"] intValue]
                      authOptions:JDOGetOauthOptions(nil)
                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                               if (result){
                                   [item setObject:[userInfo nickname] forKey:@"username"];
                                   [item setObject:[NSNumber numberWithBool:true] forKey:@"selected"];
                                   [_shareTypeArray writeToFile:JDOGetDocumentFilePath(@"authListCache.plist") atomically:YES];
                                   [imageBtn setEnabled:false];
                                   [selectBtn setSelected:true];
                               }else{
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
        [centerController popToViewController:[centerController.viewControllers objectAtIndex:centerController.viewControllers.count-2] orientation:JDOTransitionToBottom animated:true];
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
            NSNumber *type = [[_shareTypeArray objectAtIndex:i] objectForKey:@"type"];
            [selectedClients addObject:type];
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
    [self backToParent];
}

- (void)onBtnClicked:(UIButton *)sender {
    int index = sender.tag - Btn_Base_Tag;
    NSMutableDictionary *item = [_shareTypeArray objectAtIndex:index];
    ShareType shareType = [[item objectForKey:@"type"] intValue];
    
    if([ShareSDK hasAuthorizedWithType:shareType] ){
        if (sender.state & UIControlStateSelected){
            [item setObject:[NSNumber numberWithBool:false] forKey:@"selected"];
            [sender setSelected:false];
        }else{
            [item setObject:[NSNumber numberWithBool:true] forKey:@"selected"];
            [sender setSelected:true];
        }
        [_shareTypeArray writeToFile:JDOGetDocumentFilePath(@"authListCache.plist") atomically:YES];
    }else{
        UIButton *shareImage = (UIButton *)[self.mainView viewWithTag:Image_Base_Tag+index];
        [shareImage setBackgroundImage:[UIImage imageNamed:[enableImageNames objectAtIndex:index]] forState:UIControlStateNormal];
        [self getAuth:shareImage];
    }
    
}
#pragma mark TextView
- (void)textViewDidChange:(UITextView *)textView{
    if(textView == self.textView2){
        int textCount = [textView.text  length];
        int remaind = 130 - textCount - [_titleLabel.text length];
        if (remaind >= 0) {
            self.remainWordLabel.text = [NSString stringWithFormat:@"还可以输入%d字",remaind];
        } else {
            _textView2.text = [_textView2.text substringWithRange:NSMakeRange(0, 130 -1- [_titleLabel.text length])];
        }
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text length] == 0){
        return YES;
    }
    if([textView.text length] + range.length >= 135){
        return NO;
    }
    return YES;
}
@end

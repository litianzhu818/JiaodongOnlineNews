//
//  JDOToolBar.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-26.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOToolBar.h"
#import "CMPopTipView.h"
#import "JDOShareViewController.h"
#import "JDONewsReviewView.h"
#import "HPTextViewInternal.h"
#import <ShareSDK/ShareSDK.h>
#import "JDOShareViewDelegate.h"
#import "UIDevice+IdentifierAddition.h"
#import "JDOImageModel.h"
#import "MBProgressHUD.h"

#define Toolbar_Btn_Size 47
#define Toolbar_Height   44

#define Font_Selected_Color [UIColor blueColor]
#define Font_Unselected_Color [UIColor whiteColor]
#define PoptipView_Autodismiss_Delay 1.0

#define Review_Panel_Init_Height 40+30
#define Review_Comment_Placeholder @"说点什么吧..."

@interface JDOToolBar ()

@property (assign, nonatomic) BOOL isKeyboardShowing;
@property (strong, nonatomic) UIButton *selectedFontBtn;
@property (strong, nonatomic) CMPopTipView *fontPopTipView;
@property (strong, nonatomic) CMPopTipView *collectPopTipView;
@property (strong, nonatomic) JDOShareViewController *shareViewController;
@property (strong, nonatomic) JDONewsReviewView *reviewPanel;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation JDOToolBar{
    // 在键盘事件的通知中获得以下参数，用来同步视图动画和键盘动画
    CGRect endFrame;
    NSTimeInterval timeInterval;
}

- (id)initWithModel:(id<JDOToolbarModel>)model parentView:(UIView *)parentView config:(NSArray *)btnConfig height:(CGFloat) toolbarHeight theme:(ToolBarTheme)theme{
    self = [super init];
    if (self) {
        self.model = model;
        self.parentView = parentView;
        self.btnConfig = btnConfig;
        self.theme = theme;
        self.frameHeight = toolbarHeight;
#warning 查询该新闻是否被收藏
        _collected = false;
        _isKeyboardShowing = false;
        
        [self setupToolBar];
    }
    return self;
}

- (void)dealloc{
    [self setReviewPanel:nil];
    [self setFontPopTipView:nil];
    [self setCollectPopTipView:nil];
    [self setParentView:nil];
    [self setModel:nil];
    [self setBtnConfig:nil];
    [self setBridge:nil];
    [self setShareViewController:nil];
}

- (void) setupToolBar{
    self.frame = CGRectMake(0, App_Height-self.frameHeight, 320, self.frameHeight);
    self.backgroundColor = [UIColor clearColor];
    UIImageView *toolBackground = [[UIImageView alloc] initWithFrame:self.bounds];
    toolBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if(_theme == ToolBarThemeWhite){
        toolBackground.image = [UIImage imageNamed:@"toolbar_white_background.png"];
    }else if(_theme == ToolBarThemeBlack){
        toolBackground.image = [UIImage imageNamed:@"toolbar_black_background.png"];
    }
    [self addSubview:toolBackground];
    
    for(int i =0;i<_btnConfig.count;i++ ){
        float perBtnWidth = 320.0/_btnConfig.count;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*perBtnWidth+(perBtnWidth-Toolbar_Btn_Size)/2, _frameHeight-Toolbar_Height + (Toolbar_Height-Toolbar_Btn_Size)/2.0, Toolbar_Btn_Size, Toolbar_Btn_Size)];
        ToolBarButtonType btnType = [(NSNumber *)[_btnConfig objectAtIndex:i] intValue];
        if( btnType == ToolBarButtonCollect && self.isCollected){
#warning 替换收藏过的图片
            [btn setBackgroundImage:[UIImage imageNamed:@"isCollected"] forState:UIControlStateNormal];
        }else{
            [self configButton:btn withType:btnType];
        }
        [self addSubview:btn];
    }
}

- (void) configButton:(UIButton *)btn withType:(ToolBarButtonType)btnType{
    NSString *iconName ;
    NSString *iconHighlightName ;
    switch (btnType) {
        case ToolBarButtonReview:
            iconName = @"review.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"review_highlight.png";
            }
            [btn addTarget:self action:@selector(writeReview) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ToolBarButtonShare:
            iconName = @"share.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"share_highlight.png";
            }
            [btn addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ToolBarButtonFont:
            iconName = @"font.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"font_highlight.png";
            }
            [btn addTarget:self action:@selector(popupFontPanel:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ToolBarButtonCollect:
            iconName = @"collect.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"collect_highlight.png";
            }
            [btn addTarget:self action:@selector(onCollect:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ToolBarButtonDownload:
            iconName = @"download.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"download_highlight.png";
            }
            [btn addTarget:self action:@selector(onDownload:) forControlEvents:UIControlEventTouchUpInside];
            break;
    }
    [btn setBackgroundImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    if( iconHighlightName != nil){
        [btn setBackgroundImage:[UIImage imageNamed:iconHighlightName] forState:UIControlStateHighlighted];
    }
}

#pragma mark - Write Review

- (void)writeReview{
    if( _reviewPanel == nil){
        _reviewPanel = [[JDONewsReviewView alloc] initWithTarget:self];
        [(HPTextViewInternal *)_reviewPanel.textView.internalTextView setPlaceholder:Review_Comment_Placeholder];
    }
    
    [self.parentView pushView:_reviewPanel process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        [_reviewPanel.textView becomeFirstResponder];
        _isKeyboardShowing = true;
        *_startFrame = _reviewPanel.frame;
        *_endFrame = endFrame;
        *_timeInterval = timeInterval;
    } complete:^{
        
    }];
}

- (void)hideReviewView{
    [_reviewPanel.textView resignFirstResponder];
    _isKeyboardShowing = false;
    [_reviewPanel popView:self.parentView process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        *_startFrame = _reviewPanel.frame;
        *_endFrame = CGRectMake(0, App_Height, 320, _reviewPanel.frame.size.height);
        *_timeInterval = timeInterval;
    } complete:^{
        [_reviewPanel removeFromSuperview];
    }];
}

- (void)submitReview:(id)sender{
    
    if(JDOIsEmptyString(_reviewPanel.textView.text) || [[_reviewPanel.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:Review_Comment_Placeholder]){
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:self.model.id forKey:@"aid"];
    [params setObject:[_reviewPanel.textView.text stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] forKey:@"content"];
    [params setObject:@"" forKey:@"nickName"];
    [params setObject:@"" forKey:@"uid"];
    [params setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:[self.model reviewService] modelClass:nil params:params success:^(NSDictionary *result) {
        NSNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 1 || [status intValue] == 2){ // 1:提交成功 2:重复提交,隐藏键盘
            // 清空内容，重设键盘高度
            _reviewPanel.textView.text = nil;
            _reviewPanel.frame = [_reviewPanel initialFrame];
            [_reviewPanel.remainWordNum setHidden:true];
            [self hideReviewView];
        }else if([status intValue] == 0){
            // 提交失败,服务器错误
            NSLog(@"提交失败,服务器错误");
            [JDOCommonUtil showHintHUD:@"服务器错误" inView:self.parentView];
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [JDOCommonUtil showHintHUD:errorStr inView:self.parentView];
    }];
    
    // 同时发布到微博
    [self shareReview];
}

- (void)shareReview{
    NSArray *selectedClients = [_reviewPanel selectedClients];
    if ([selectedClients count] == 0) {
        return;
    }
    
    id<ISSContent> publishContent = [ShareSDK content:[_reviewPanel.textView.text stringByAppendingString:[self defaultShareContent]]
                                       defaultContent:nil
                                                image:nil
                                                title:[self.model title]
                                                  url:@"http://m.jiaodong.net"
                                          description:[self.model summary]
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK oneKeyShareContent:publishContent
                       shareList:selectedClients
                     authOptions:JDOGetOauthOptions(nil)
                   statusBarTips:YES
                          result:nil];
}

- (NSString *)defaultShareContent{
    return [NSString stringWithFormat:@" //评论胶东在线新闻【%@】 http://m.jiaodong.net",[self.model title]];
}

#pragma mark - keyboard notification

// 显示键盘和切换输入法时都会执行
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    // self.parentView会scale到0.95，所以用superview(UIViewControllerWrapperView)作为参考系
    keyboardRect = [self.parentView.superview convertRect:keyboardRect fromView:nil];
    
    CGRect reviewPanelFrame = _reviewPanel.frame;
    reviewPanelFrame.origin.y = self.parentView.bounds.size.height - (keyboardRect.size.height + reviewPanelFrame.size.height);
    CGRect _endFrame = reviewPanelFrame;
    
    if( _isKeyboardShowing == false){
        endFrame = _endFrame;
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [animationDurationValue getValue:&timeInterval];
    }else{
        _reviewPanel.frame = _endFrame;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [animationDurationValue getValue:&timeInterval];
}

#pragma mark - Share

- (void) setupSharePanel{
    if( _shareViewController == nil){
        _shareViewController = [[JDOShareViewController alloc] initWithModel:self.model];
    };
}

- (void) onShare{
    [self setupSharePanel];
    if(self.shareTarget && [self.shareTarget respondsToSelector:@selector(onSharedClicked)]){
        [self.shareTarget onSharedClicked];
    }
    [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController  pushViewController:_shareViewController orientation:JDOTransitionFromBottom animated:true];
}

#pragma mark - Font

- (void) popupFontPanel:(UIButton *)sender{
    if(_fontPopTipView == nil){
        UIView *fontView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        NSArray *fontLabelName = @[@"小",@"中",@"大"];
        NSArray *fontCSSName = @[@"small_font",@"normal_font",@"big_font"];
        NSArray *fontSize = @[@16,@18,@20];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *fontClass = [userDefault objectForKey:@"font_class"];
        if(fontClass == nil)    fontClass = @"normal_font";
        for(int i=0;i<3;i++){
            UIButton *fontBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*40, 0, 40, 20)];
            [fontBtn setTitle:[fontLabelName objectAtIndex:i] forState:UIControlStateNormal];
            [fontBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:[[fontSize objectAtIndex:i] intValue]]];
            [fontBtn addTarget:self action:@selector(changeFontSize:) forControlEvents:UIControlEventTouchUpInside];
            [fontBtn setTitleColor:Font_Unselected_Color forState:UIControlStateNormal];
            [fontBtn setTitleColor:Font_Selected_Color forState:UIControlStateSelected];
            if([fontClass isEqualToString:[fontCSSName objectAtIndex:i]]){
                self.selectedFontBtn = fontBtn;
                [fontBtn setSelected:true];
            }else{
                [fontBtn setSelected:false];
            }
            [fontView addSubview:fontBtn];
        }
        _fontPopTipView = [[CMPopTipView alloc] initWithCustomView:fontView];
        _fontPopTipView.disableTapToDismiss = YES;
        _fontPopTipView.preferredPointDirection = PointDirectionDown;
        _fontPopTipView.backgroundColor = [UIColor darkGrayColor];
        _fontPopTipView.animation = CMPopTipAnimationPop;
        _fontPopTipView.dismissTapAnywhere = YES;
    }
    [_fontPopTipView presentPointingAtView:sender inView:self.parentView animated:YES];
}

- (void) changeFontSize:(UIButton *)sender{
    if(self.selectedFontBtn == sender)  return;
    self.selectedFontBtn = sender;
    NSArray *fontLabelName = @[@"小",@"中",@"大"];
    NSArray *fontCSSName = @[@"small_font",@"normal_font",@"big_font"];
    NSString *title = [sender titleForState:UIControlStateNormal];
    [sender setSelected:true];
    for(UIView *otherBtn in [[sender superview] subviews]){
        if([otherBtn isKindOfClass:[UIButton class]] && otherBtn!=sender){
            [(UIButton *)otherBtn setSelected:false];
        }
    }
    NSString *selectedFontCSSName = [fontCSSName objectAtIndex:[fontLabelName indexOfObject:title]];
    [_bridge callHandler:@"changeFontSize" data:selectedFontCSSName];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:selectedFontCSSName forKey:@"font_class"];
    [userDefault synchronize];
    [_fontPopTipView.autoDismissTimer invalidate];
    [_fontPopTipView autoDismissAnimated:true atTimeInterval:PoptipView_Autodismiss_Delay];
}

#pragma mark - Collect

- (void) onCollect:(UIButton *)sender{
    if(_collectPopTipView == nil){
        _collectPopTipView = [[CMPopTipView alloc] initWithMessage:@""];
        _collectPopTipView.disableTapToDismiss = YES;
        _collectPopTipView.preferredPointDirection = PointDirectionDown;
        _collectPopTipView.backgroundColor = [UIColor darkGrayColor];
        _collectPopTipView.animation = CMPopTipAnimationPop;
        _collectPopTipView.dismissTapAnywhere = NO;
    }
    if(self.isCollected){
#warning 取消收藏
        self.collected = false;
        _collectPopTipView.message = @"  取消收藏!  ";
    }else{
        self.collected = true;
        _collectPopTipView.message = @"  收藏成功!  ";
    }
    [_collectPopTipView presentPointingAtView:sender inView:self.parentView animated:YES];
    [_collectPopTipView autoDismissAnimated:true atTimeInterval:PoptipView_Autodismiss_Delay];
}

- (void) onDownload:(UIButton *)sender{
    if(self.downloadTarget && [self.downloadTarget respondsToSelector:@selector(getDownloadObject)]){
        id downloadObject = [self.downloadTarget getDownloadObject];
        if(downloadObject){
            [self showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , @"保存中"]];
            [self performSelector:@selector(actuallyDownload:) withObject:downloadObject afterDelay:0];
        }else{
            // 重新异步加载需要下载的对象
            if( [self.downloadTarget respondsToSelector:@selector(addObserver:selector:)]){
                [self.downloadTarget addObserver:self selector:@selector(onDownloadObjectFinished)];
            }
        }
    }
}

- (void) onDownloadObjectFinished{
    id downloadObject = [self.downloadTarget getDownloadObject];
    if(downloadObject){
        [self showProgressHUDWithMessage:[NSString stringWithFormat:@"%@\u2026" , @"保存中"]];
        [self performSelector:@selector(actuallyDownload:) withObject:downloadObject afterDelay:0];
    }
    if( [self.downloadTarget respondsToSelector:@selector(removeObserver:)]){
        [self.downloadTarget removeObserver:self];
    }
}

- (void)actuallyDownload:(id)downloadObject {
    // 保存图片
    if([downloadObject isKindOfClass:[UIImage class]]){
        UIImageWriteToSavedPhotosAlbum((UIImage *)downloadObject, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self showProgressHUDCompleteMessage: error ? @"保存失败" : @"保存成功"];
}

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.parentView];
//        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;

        self.progressHUD.customView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/Checkmark.png"]];
        [self.parentView addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if (message) {
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.5];
    } else {
        [self.progressHUD hide:YES];
    }
}

@end

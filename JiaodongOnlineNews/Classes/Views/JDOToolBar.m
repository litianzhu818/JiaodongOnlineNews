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
#import "JDOQuestionReviewController.h"

#define Toolbar_Control_Default_Width 47
#define Toolbar_Control_Default_Height 47
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
@property (nonatomic, strong) JDOQuestionReviewController *questionReviewController;

@end

@implementation JDOToolBar{
    // 在键盘事件的通知中获得以下参数，用来同步视图动画和键盘动画
    CGRect endFrame;
    NSTimeInterval timeInterval;
}

// widthConfig中保存NSDictionary,包括"controlWidth","frameWidth","controlHeight"
- (id)initWithModel:(id<JDOToolbarModel>)model parentController:(UIViewController *)parentController typeConfig:(NSArray *)typeConfig widthConfig:(NSArray *)widthConfig frame:(CGRect) frame theme:(ToolBarTheme)theme{
    self = [super initWithFrame:frame];
    if (self) {
        self.model = model;
        self.parentController = parentController;
        self.typeConfig = typeConfig;
        self.widthConfig = widthConfig;
        self.theme = theme;
        self.frameHeight = frame.size.height;
        self.btns = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        _isKeyboardShowing = false;
        _reviewType = JDOReviewTypeNews;
        self.collectDB = [[JDOCollectDB alloc] init];
        _collected = [self.collectDB isExistById:model.id];
        [self setupToolBar];
    }
    return self;
}

- (void)dealloc{
    [self setReviewPanel:nil];
    [self setFontPopTipView:nil];
    [self setCollectPopTipView:nil];
    [self setParentController:nil];
    [self setModel:nil];
    [self setTypeConfig:nil];
    [self setWidthConfig:nil];
    [self setBridge:nil];
    [self setShareViewController:nil];
    self.collectDB = nil;
}

- (void) setupToolBar{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *toolBackground = [[UIImageView alloc] initWithFrame:self.bounds];
    toolBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if(_theme == ToolBarThemeWhite){
        toolBackground.image = [UIImage imageNamed:@"toolbar_white_background.png"];
    }else if(_theme == ToolBarThemeBlack){
        toolBackground.image = [UIImage imageNamed:@"toolbar_black_background.png"];
    }
    [self addSubview:toolBackground];
    
    float xPosition = 0;
    for(int i =0;i<_typeConfig.count;i++ ){
        float frameWidth = 0, controlWidth = 0, controlHeight = 0;
        if(_widthConfig == nil){
            frameWidth = 320.0/_typeConfig.count;
            controlWidth = Toolbar_Control_Default_Width;
            controlHeight = Toolbar_Control_Default_Height;
        }else{
            frameWidth = [[[_widthConfig objectAtIndex:i] objectForKey:@"frameWidth"] floatValue];
            controlWidth = [[[_widthConfig objectAtIndex:i] objectForKey:@"controlWidth"] floatValue];
            controlHeight = [[[_widthConfig objectAtIndex:i] objectForKey:@"controlHeight"] floatValue];
        }
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(xPosition+(frameWidth-controlWidth)/2, _frameHeight-Toolbar_Height + (Toolbar_Height-controlHeight)/2.0, controlWidth, controlHeight)];
        xPosition += frameWidth;
        
        ToolBarControlType btnType = [(NSNumber *)[_typeConfig objectAtIndex:i] intValue];
        [self.btns setObject:btn forKey:[NSNumber numberWithInt:btnType]];
        if( btnType == ToolBarInputField ){ // 工具栏包含输入框的情况
            [btn setBackgroundImage:[UIImage imageNamed:@"inputFieldBorder"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"inputFieldBorder"] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(writeReview) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [self configButton:btn withType:btnType];
        }
        [self addSubview:btn];
    }
}

- (void) configButton:(UIButton *)btn withType:(ToolBarControlType)btnType{
    NSString *iconName ;
    NSString *iconHighlightName ;
    switch (btnType) {
        case ToolBarButtonReview:
            iconName = @"review.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"review_highlight.png";
            }else if(_theme == ToolBarThemeWhite){
                // 若不设置高亮图片,默认高亮清晰度有问题
                iconHighlightName = @"review_clicked.png";
            }
            [btn addTarget:self action:@selector(writeReview) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ToolBarButtonShare:
            iconName = @"share.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"share_highlight.png";
            }else if(_theme == ToolBarThemeWhite){
                iconHighlightName = @"share_clicked.png";
            }
            [btn addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ToolBarButtonFont:
            iconName = @"font.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"font_highlight.png";
            }else if(_theme == ToolBarThemeWhite){
                iconHighlightName = @"font_clicked.png";
            }
            [btn addTarget:self action:@selector(popupFontPanel:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ToolBarButtonCollect:
            iconName = @"collect.png";
            if (_theme == ToolBarThemeBlack) {
                iconHighlightName = @"collect_highlight.png";
            }else if(_theme == ToolBarThemeWhite){
                iconHighlightName = @"collect_clicked.png";
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
        case ToolBarButtonVideoEpg:
            iconName = @"epg.png";
            iconHighlightName = @"epg_clicked.png";
            [btn addTarget:self action:@selector(onVideoEpg:) forControlEvents:UIControlEventTouchUpInside];
        default:
            break;
    }
    [btn setBackgroundImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    if( iconHighlightName != nil){
        [btn setBackgroundImage:[UIImage imageNamed:iconHighlightName] forState:UIControlStateHighlighted];
    }
    if(btnType == ToolBarButtonCollect ){
        [btn setBackgroundImage:[UIImage imageNamed:@"collect_save.png"] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"collect_savehighlight.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
        if(self.isCollected){
            [btn setSelected:TRUE];
        }else{
            [btn setSelected:FALSE];
        }
    }
    
}

#pragma mark - Write Review

- (void)writeReview{
    if( _reviewType == JDOReviewTypeNews){
        if( _reviewPanel == nil){
            _reviewPanel = [[JDONewsReviewView alloc] initWithTarget:self];
            [(HPTextViewInternal *)_reviewPanel.textView.internalTextView setPlaceholder:Review_Comment_Placeholder];
        }
        
        [self.parentController.view pushView:_reviewPanel process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
            [_reviewPanel.textView becomeFirstResponder];
            // po [[[[UIApplication sharedApplication] windows] lastObject] subviews] 可以用来查看键盘所在的view
            _isKeyboardShowing = true;
            *_startFrame = _reviewPanel.frame;
            *_endFrame = endFrame;
            *_timeInterval = timeInterval;
        } complete:^{
            
        }];
    }else if( _reviewType == JDOReviewTypeLivehood){
        // 民声评论需要输入的内容较多，在新页面打开
        if (_questionReviewController == nil){
            _questionReviewController = [[JDOQuestionReviewController alloc] initWithQuestionModel:(JDOQuestionModel *)self.model];
        }
        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
        [centerController pushViewController:_questionReviewController animated:true];
    }
    
}

- (void)hideReviewView{
    [_reviewPanel.textView resignFirstResponder];
    _isKeyboardShowing = false;
    [_reviewPanel popView:self.parentController.view process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        *_startFrame = _reviewPanel.frame;
        *_endFrame = CGRectMake(0, App_Height, 320, _reviewPanel.frame.size.height);
        *_timeInterval = timeInterval;
    } complete:^{
        [_reviewPanel removeFromSuperview];
    }];
}

- (void)submitReview:(id)sender{
    
    if(JDOIsEmptyString(_reviewPanel.textView.text) /*|| [[_reviewPanel.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:Review_Comment_Placeholder]*/){
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:self.model.id forKey:@"aid"];
    [params setObject:[_reviewPanel.textView.text stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] forKey:@"content"];
    [params setObject:@"" forKey:@"nickName"];
    [params setObject:@"" forKey:@"uid"];
    [params setObject:JDOGetUUID() forKey:@"deviceId"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:[self.model reviewService] modelClass:nil params:params success:^(NSDictionary *result) {
        NSNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 1 || [status intValue] == 2){ // 1:提交成功 2:重复提交,隐藏键盘
            // 清空内容，重设键盘高度
            _reviewPanel.textView.text = nil;
            _reviewPanel.frame = [_reviewPanel initialFrame];
            [_reviewPanel.remainWordNum setHidden:true];
            
            if ([_reviewPanel superview]) {
                [self performSelector:@selector(showSuccessNotice:) withObject:@"发表评论成功" afterDelay:0.2];
            }else{
                [self showSuccessNotice:@"发表评论成功"];
            }
        }else if([status intValue] == 0){
            // 提交失败,服务器错误
            if ([_reviewPanel superview]) {
                [self performSelector:@selector(showErrorNotice:) withObject:@"服务器错误" afterDelay:0.2];
            }else{
                [self showErrorNotice:@"服务器错误"];
            }
        }
    } failure:^(NSString *errorStr) {
        if ([_reviewPanel superview]) {
            [self performSelector:@selector(showErrorNotice:) withObject:errorStr afterDelay:0.2];
        }else{
            [self showErrorNotice:errorStr];
        }
    }];
    [self hideReviewView];
    
    // 同时发布到微博
    [self shareReview];
}

- (void) showSuccessNotice:(NSString *)content{
#warning 为了跳过导航视图的高度,加在内容的webView视图上,结构上更好的办法对parentController设置协议
    if ([self.parentController respondsToSelector:@selector(webView)]){
        [JDOCommonUtil showSuccessHUD:content inView:[self.parentController performSelector:@selector(webView)]];
    }else if ([self.parentController respondsToSelector:@selector(tableView)]){
        [JDOCommonUtil showSuccessHUD:content inView:[self.parentController performSelector:@selector(tableView)]];
    }else{
        [JDOCommonUtil showSuccessHUD:content inView:self.parentController.view];
    }
    // 在评论列表页面,发表完评论后应该自动刷新
    if( [self.parentController respondsToSelector:@selector(refresh)]){
        [self.parentController performSelector:@selector(refresh)];
    }
}
- (void) showErrorNotice:(NSString *)content{
    if ([self.parentController respondsToSelector:@selector(webView)]){
        [JDOCommonUtil showHintHUD:content inView:[self.parentController performSelector:@selector(webView)]];
    }else if ([self.parentController respondsToSelector:@selector(tableView)]){
        [JDOCommonUtil showHintHUD:content inView:[self.parentController performSelector:@selector(tableView)]];
    }else{
        [JDOCommonUtil showHintHUD:content inView:self.parentController.view];
    }
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
                                                  url:[self.model tinyurl]
                                          description:[self.model summary]
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK oneKeyShareContent:publishContent
                       shareList:selectedClients
                     authOptions:JDOGetOauthOptions(nil)
                   statusBarTips:Is_iOS7?false:true
                          result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                              if(error){
                                  NSLog(@"平台:%@,错误代码:%d,描述:%@",[ShareSDK getClientNameWithType:type], [error errorCode],[error errorDescription]);
                              }
                          }];
}

- (NSString *)defaultShareContent{
    return [NSString stringWithFormat:@" //评论胶东在线新闻【%@】 %@",[self.model title],[self.model tinyurl]];
}

#pragma mark - keyboard notification

// 显示键盘和切换输入法时都会执行
- (void)keyboardWillShow:(NSNotification *)notification{
    if(!JDOIsVisiable(self)){
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    // self.parentView会scale到0.95，所以用superview(UIViewControllerWrapperView)作为参考系
    keyboardRect = [self.parentController.view.superview convertRect:keyboardRect fromView:nil];
    
    CGRect reviewPanelFrame = _reviewPanel.frame;
    reviewPanelFrame.origin.y = App_Height - (keyboardRect.size.height + reviewPanelFrame.size.height);
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
    if(!JDOIsVisiable(self)){
        return;
    }
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
        if ([self.shareTarget onSharedClicked]) {
            [(JDOCenterViewController *)SharedAppDelegate.deckController.centerController  pushViewController:_shareViewController orientation:JDOTransitionFromBottom animated:true];
        }
    }
}

#pragma mark - Font

- (void) popupFontPanel:(UIButton *)sender{
    if(_fontPopTipView == nil){
        UIView *fontView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        NSArray *fontLabelName = @[@"小",@"中",@"大"];
        NSArray *fontCSSName = @[@"small_font",@"normal_font",@"big_font"];
        NSArray *fontSize = @[@16,@18,@20];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *fontClass = [userDefault objectForKey:@"font_class"];
        if(fontClass == nil)    fontClass = @"normal_font";
        for(int i=0;i<3;i++){
            UIButton *fontBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*50, 0, 50, 40)];
            [fontBtn setTitle:[fontLabelName objectAtIndex:i] forState:UIControlStateNormal];
            [fontBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:[[fontSize objectAtIndex:i] intValue]]];
            [fontBtn addTarget:self action:@selector(changeFontSize:) forControlEvents:UIControlEventTouchUpInside];
            [fontBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [fontBtn setTitleColor:[UIColor colorWithHex:@"0078c8"] forState:UIControlStateSelected];
            [fontBtn setBackgroundColor:[UIColor clearColor]];
            [fontBtn setBackgroundImage:[UIImage imageNamed:@"background_black"] forState:UIControlStateSelected];

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
        //_fontPopTipView.backgroundColor = [UIColor clearColor];
        _fontPopTipView.animation = CMPopTipAnimationPop;
        _fontPopTipView.dismissTapAnywhere = YES;
    }
    [_fontPopTipView presentPointingAtView:sender inView:self.parentController.view animated:YES];
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
        _collectPopTipView.animation = CMPopTipAnimationPop;
        _collectPopTipView.dismissTapAnywhere = NO;
    }
    if(self.isCollected){
        if([self.collectDB deleteById:self.model.id]){
            self.collected = false;
            _collectPopTipView.message = @" 取消收藏   ";
            [sender setSelected:FALSE];
        }
        
    }else{
        if([self.collectDB save:self.model]){
            self.collected = true;
            _collectPopTipView.message = @" 收藏成功   ";
            [sender setSelected:TRUE];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kCollectNotification object:nil];
    [_collectPopTipView presentPointingAtView:sender inView:self.parentController.view animated:YES];
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

- (void) onVideoEpg:(UIButton *)sender{
    if(self.videoTarget){
        [self.videoTarget onEpgClicked];
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
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.parentController.view];
//        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        _progressHUD.margin = 15.f;

        self.progressHUD.customView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark.png"]];
        [self.parentController.view addSubview:_progressHUD];
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

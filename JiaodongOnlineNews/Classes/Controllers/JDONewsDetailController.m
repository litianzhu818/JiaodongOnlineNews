//
//  JDONewsDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsDetailController.h"
#import "UIWebView+RemoveShadow.h"
#import "JDONewsModel.h"
#import "JDOWebClient.h"
#import "JDONewsDetailModel.h"
#import "JDOCenterViewController.h"
#import "WebViewJavascriptBridge_iOS.h"
#import "UIDevice+IdentifierAddition.h"
#import "JDOReviewListController.h"
#import "NSString+SSToolkitAdditions.h"
#import "UIColor+SSToolkitAdditions.h"
#import "CMPopTipView.h"
#import "JDOShareViewController.h"
#import "JDONewsReviewView.h"
#import "HPTextViewInternal.h"

#define Toolbar_Tag 100
#define Review_Tag  100
#define Share_Tag   101
#define Font_Tag    102
#define Collect_Tag 103

#define Toolbar_Btn_Size 32
#define Toolbar_Height   40

#define Font_Selected_Color [UIColor blueColor]
#define Font_Unselected_Color [UIColor whiteColor]
#define PoptipView_Autodismiss_Delay 1.0

#define Review_Panel_Init_Height 40+30
#define Review_Comment_Placeholder @"说点什么吧..."

@interface JDONewsDetailController ()

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) JDONewsReviewView *reviewPanel;
@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (assign, nonatomic) BOOL isKeyboardShowing;
@property (strong, nonatomic) UIButton *selectedFontBtn;
@property (strong, nonatomic) CMPopTipView *fontPopTipView;
@property (assign, nonatomic,getter = isCollected) BOOL collected;
@property (strong, nonatomic) CMPopTipView *collectPopTipView;
@property (strong, nonatomic) JDOShareViewController *shareViewController;

@end

@implementation JDONewsDetailController{

}

- (id)initWithNewsModel:(JDONewsModel *)newsModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.newsModel = newsModel;
#warning 查询该新闻是否被收藏
        self.collected = false;
        self.isKeyboardShowing = false;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)loadView{
    [super loadView];
    // 自定义导航栏
    [self setupNavigationView];
    // 内容
    self.view.backgroundColor = [UIColor colorWithHex:@"f6f6f6"];// 与html的body背景色相同
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44-Toolbar_Height)]; // 去掉导航栏和工具栏
    [self.webView makeTransparentAndRemoveShadow];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = true;
    [self.view addSubview:_webView];
    // 工具栏
    [self setupToolBar];
    
    // WebView加载mask
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height)];
    [maskView setTag:108];
    [maskView setBackgroundColor:[UIColor blackColor]];
    [maskView setAlpha:0.3];
    [self.view addSubview:maskView];
    
    self.activityIndicationView = [[UIActivityIndicatorView alloc] init];
    self.activityIndicationView.center = self.webView.center;
    self.activityIndicationView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:_activityIndicationView];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self buildWebViewJavascriptBridge];
    [self loadWebView];
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideReviewView)];
    [self.view.blackMask addGestureRecognizer:self.closeReviewGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:_reviewPanel.textView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:_reviewPanel.textView];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [self setWebView:nil];
    [self setReviewPanel:nil];
    [self setFontPopTipView:nil];
    [self setCollectPopTipView:nil];
    
    [self.view.blackMask removeGestureRecognizer:self.closeReviewGesture];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:_reviewPanel.textView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:_reviewPanel.textView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void) setupNavigationView{
    self.navigationView = [[JDONavigationView alloc] init];
    [_navigationView addBackButtonWithTarget:self action:@selector(backToViewList)];
    [_navigationView setTitle:@"新闻详情"];
    [_navigationView addRightButtonImage:@"review_item" highlightImage:@"review_item" target:self action:@selector(showReviewList)];
    [self.view addSubview:_navigationView];
}

- (void) backToViewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void) showReviewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithParams:@{@"aid":self.newsModel.id,@"deviceId":[[UIDevice currentDevice] uniqueDeviceIdentifier]}];
    [centerViewController pushViewController:reviewController animated:true];
}

#pragma mark - ToolBar

- (void) setupToolBar{
    NSArray *icons = @[@"review",@"share",@"font",@"collect"];
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, App_Height-Toolbar_Height, 320, Toolbar_Height)];
    for(int i =0;i<4;i++ ){
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*80+(80-Toolbar_Btn_Size)/2, 4, Toolbar_Btn_Size, Toolbar_Btn_Size)];
        if( i==3 && self.isCollected){
#warning 替换收藏过的图片
            [btn setBackgroundImage:[UIImage imageNamed:@"isCollected"] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:[icons objectAtIndex:i]] forState:UIControlStateNormal]; 
        }
        
        [btn setTag:Toolbar_Tag+i];
        [btn addTarget:self action:@selector(toolbarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:btn];
    }
    [self.view addSubview:toolView];
}

- (void) toolbarBtnClicked:(UIButton *)sender{
    switch (sender.tag) {
        case Review_Tag:
            [self writeReview]; break;
        case Share_Tag:
            [self shareNews];   break;
        case Font_Tag:
            [self popupFontPanel:sender];   break;
        case Collect_Tag:
            [self collectNews:sender];  break;
    }
}

#pragma mark - Write Review

// 在键盘事件的通知中获得以下参数，用来同步视图动画和键盘动画
CGRect endFrame;
NSTimeInterval timeInterval;

- (void)writeReview{
    if( _reviewPanel == nil){
        _reviewPanel = [[JDONewsReviewView alloc] initWithFrame:CGRectMake(0, App_Height, 320, Review_Panel_Init_Height) controller:self];
        [(HPTextViewInternal *)_reviewPanel.textView.internalTextView setPlaceholder:Review_Comment_Placeholder];
    }
    
    [self.view pushView:_reviewPanel process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        [_reviewPanel.textView becomeFirstResponder];
        _isKeyboardShowing = true;
        *_startFrame = _reviewPanel.frame;
        *_endFrame = endFrame;
        *_timeInterval = timeInterval;
    } complete:^{
        
    }];
}

// 显示键盘和切换输入法时都会执行
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    // self.view会scale到0.95，所以用superview(UIViewControllerWrapperView)作为参考系
    keyboardRect = [self.view.superview convertRect:keyboardRect fromView:nil];
    
//    _reviewPanel.frame = CGRectMake(0, App_Height, 320, Review_Panel_Init_Height);
    CGRect reviewPanelFrame = _reviewPanel.frame;
    reviewPanelFrame.origin.y = self.view.bounds.size.height - (keyboardRect.size.height + reviewPanelFrame.size.height);
    CGRect _endFrame = reviewPanelFrame;
    
    if( _isKeyboardShowing == false){
        endFrame = _endFrame;
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [animationDurationValue getValue:&timeInterval];
    }else{
        _reviewPanel.frame = _endFrame;
    }
}

- (void)hideReviewView{
    [_reviewPanel.textView resignFirstResponder];
    _isKeyboardShowing = false;
    [_reviewPanel popView:self.view process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        *_startFrame = _reviewPanel.frame;
        *_endFrame = CGRectMake(0, App_Height, 320, _reviewPanel.frame.size.height);
        *_timeInterval = timeInterval;
    } complete:^{
        [_reviewPanel removeFromSuperview];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [animationDurationValue getValue:&timeInterval];
}

- (void)submitReview:(id)sender{
    
    if(JDOIsEmptyString(_reviewPanel.textView.text) || [[_reviewPanel.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:Review_Comment_Placeholder]){
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:self.newsModel.id forKey:@"aid"];
    [params setObject:[_reviewPanel.textView.text stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] forKey:@"content"];
    [params setObject:@"" forKey:@"nickName"];
    [params setObject:@"" forKey:@"uid"];
    [params setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:COMMIT_COMMENT_SERVICE modelClass:nil params:params success:^(NSDictionary *result) {
        NSNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 1){ // 提交成功,隐藏键盘
            // 清空内容，重设键盘高度
            _reviewPanel.textView.text = nil;
            CGRect reviewPanelFrame = _reviewPanel.frame;
            reviewPanelFrame.size.height = Review_Panel_Init_Height;
            _reviewPanel.frame = reviewPanelFrame;
            [_reviewPanel.remainWordNum setHidden:true];
            [self hideReviewView];
        }else if([status intValue] == 0){
            // 提交失败,服务器错误
            NSLog(@"提交失败,服务器错误");
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
    }];
}

#pragma mark - Share

- (void) setupSharePanel{
    if( _shareViewController == nil){
        _shareViewController = [[JDOShareViewController alloc] init];
    };
}

- (void) shareNews{
    [self setupSharePanel];
    [(JDOCenterViewController *)self.navigationController pushViewController:_shareViewController orientation:JDOTransitionFromBottom animated:true];
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
    [_fontPopTipView presentPointingAtView:sender inView:self.view animated:YES];
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

- (void) collectNews:(UIButton *)sender{
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
    [_collectPopTipView presentPointingAtView:sender inView:self.view animated:YES];
    [_collectPopTipView autoDismissAnimated:true atTimeInterval:PoptipView_Autodismiss_Delay];
}

#pragma mark - Load WebView
     
- (void) buildWebViewJavascriptBridge{
//    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [_bridge registerHandler:@"showImageSet" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *linkId = [(NSDictionary *)data valueForKey:@"linkId"];
        // 通过pushViewController 显示图集视图
        responseCallback(linkId);
    }];
    [_bridge registerHandler:@"showImageDetail" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *imageId = [(NSDictionary *)data valueForKey:@"imageId"];
        // 显示图片详情
        responseCallback(imageId);
    }];
}

- (void) loadWebView{
    [[JDOJsonClient sharedClient] getPath:NEWS_DETAIL_SERVICE parameters:@{@"aid":self.newsModel.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]] && [(NSArray *)responseObject count]==0){
            // 新闻不存在
        }else if([responseObject isKindOfClass:[NSDictionary class]]){
//            JDONewsDetailModel *detailModel = [(NSDictionary *)responseObject jsonDictionaryToModel:[JDONewsDetailModel class]];
            NSString *mergedHTML = [JDONewsDetailModel mergeToHTMLTemplateFromDictionary:responseObject];
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tieba.baidu.com"]]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [self.activityIndicationView startAnimating];
}

#pragma mark - Webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSString *scheme = request.URL.scheme;
//    NSString *host = request.URL.host;
//    NSString *query = request.URL.query;
//    NSNumber *port = request.URL.port;
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityIndicationView stopAnimating];
    [[self.view viewWithTag:108] removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
@end

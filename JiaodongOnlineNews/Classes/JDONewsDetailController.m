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

#define Toolbar_Tag 100
#define Review_Tag  100
#define Share_Tag   101
#define Font_Tag    102
#define Collect_Tag 103

#define Toolbar_Btn_Size 32
#define Toolbar_Height   40
#define Textfield_Height 80
#define ReviewPanel_Height 90
#define SubmitBtn_Width 50

#define Review_Max_Length 200
#define Remain_Word_Label 200

@interface JDONewsDetailController ()

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) UIView *reviewPanel;
@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UITextView *textView;
@property (assign, nonatomic) BOOL isKeyboardShowing;

@end

@implementation JDONewsDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)loadView{
    [super loadView];
    // 自定义导航栏
    [self setupNavigationView];
    // 内容
    self.view.backgroundColor = [JDOCommonUtil colorFromString:@"f6f6f6"];// 与html的body背景色相同
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44-Toolbar_Height)]; // 去掉导航栏和工具栏
    [self.webView makeTransparentAndRemoveShadow];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = true;
    [self.view addSubview:_webView];
    // 工具栏
    [self setupToolBar];
    // 评论输入panel
    [self setupReviewPanel];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    
    [self.view.blackMask removeGestureRecognizer:self.closeReviewGesture];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [_navigationView addCustomButtonWithTarget:self action:@selector(showReviewList)];
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
        [btn setBackgroundImage:[UIImage imageNamed:[icons objectAtIndex:i]] forState:UIControlStateNormal];
        [btn setTag:Toolbar_Tag+i];
        [btn addTarget:self action:@selector(toolbarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:btn];
    }
    [self.view addSubview:toolView];
}

- (void) toolbarBtnClicked:(UIControl *)sender{
    switch (sender.tag) {
        case Review_Tag:
            [self writeReviewView];
            break;
        case Share_Tag:
            
            break;
        case Font_Tag:
            
            break;
        case Collect_Tag:{
            NSArray *fontSize = @[@"small_font",@"normal_font",@"big_font",@"small_font"];
            [_bridge callHandler:@"changeFontSize" data:[fontSize objectAtIndex:0]];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Write Review

- (void) setupReviewPanel{
    _isKeyboardShowing = false;
    _reviewPanel = [[UIView alloc] init];
    _reviewPanel.backgroundColor = [UIColor grayColor];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, 320-10-10-SubmitBtn_Width, Textfield_Height)];
    _textView.layer.cornerRadius = 5;
    _textView.layer.masksToBounds = true;
    _textView.font = [UIFont systemFontOfSize:16];
    [_reviewPanel addSubview:_textView];
    _textView.delegate = self;
    
    UILabel *remainWordNum = [[UILabel alloc] initWithFrame:CGRectMake(320-5-SubmitBtn_Width, 5, SubmitBtn_Width, 40)];
//    remainWordNum.text = [NSString stringWithFormat:@"还有%d字可输入",Review_Max_Length ];
    remainWordNum.tag = Remain_Word_Label;
    remainWordNum.backgroundColor =[UIColor clearColor];
    remainWordNum.numberOfLines = 2;
    remainWordNum.font = [UIFont systemFontOfSize:10];
    [_reviewPanel addSubview:remainWordNum];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect] ;
    submitBtn.frame = CGRectMake(320-5-SubmitBtn_Width, ReviewPanel_Height-5-30, SubmitBtn_Width, 30);
    [submitBtn addTarget:self action:@selector(submitReview:) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setTitle:@"发表" forState:UIControlStateNormal];
    [_reviewPanel addSubview:submitBtn];
}

// 在键盘事件的通知中获得以下参数，用来同步视图动画和键盘动画
CGRect endFrame;
NSTimeInterval timeInterval;

- (void)writeReviewView{
    
    [self.view pushView:_reviewPanel process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        [_textView becomeFirstResponder];
        _isKeyboardShowing = true;
        *_startFrame = CGRectMake(0, App_Height, 320, ReviewPanel_Height);
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
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGRect _endFrame = CGRectMake(0, keyboardTop-ReviewPanel_Height, 320, ReviewPanel_Height);
    if( _isKeyboardShowing == false){
        endFrame = _endFrame;
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [animationDurationValue getValue:&timeInterval];
    }else{
        _reviewPanel.frame = _endFrame;
    }
}

- (void)hideReviewView{
    [_textView resignFirstResponder];
    _isKeyboardShowing = false;
    [_reviewPanel popView:self.view process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        *_startFrame = _reviewPanel.frame;
        *_endFrame = CGRectMake(0, App_Height, 320, ReviewPanel_Height);
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
    
    if([JDOCommonUtil isEmptyString:_textView.text]){
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:self.newsModel.id forKey:@"aid"];
    [params setObject:_textView.text forKey:@"content"];
    [params setObject:@"" forKey:@"nickName"];
    [params setObject:@"" forKey:@"uid"];
    [params setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"deviceId"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:COMMIT_COMMENT_SERVICE modelClass:nil params:params success:^(NSDictionary *result) {
        NSNumber *status = [result objectForKey:@"status"];
        if([status intValue] == 1){ // 提交成功,隐藏键盘
            [self hideReviewView];
        }else if([status intValue] == 0){
            // 提交失败,服务器错误
            NSLog(@"提交失败,服务器错误");
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
    }];
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

#pragma mark - TextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.location>=Review_Max_Length){
        return  NO;
    }else{
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    int remain = Review_Max_Length-textView.text.length;
    [(UILabel *)[self.reviewPanel viewWithTag:Remain_Word_Label] setText:[NSString stringWithFormat:@"还有%d字可输入",remain<0 ? 0:remain]];
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    
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

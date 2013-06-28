//
//  JDOConvenienceItemController.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOConvenienceItemController.h"
#import "UIWebView+RemoveShadow.h"
#import "JDONewsModel.h"
#import "JDOWebClient.h"
#import "JDONewsDetailModel.h"
#import "JDOCenterViewController.h"
#import "UIColor+SSToolkitAdditions.h"

#define Toolbar_Tag 100
#define Review_Tag  100
#define Share_Tag   101
#define Font_Tag    102
#define Collect_Tag 103

#define Textfield_Height 40

@interface JDOConvenienceItemController ()

@end  

@implementation JDOConvenienceItemController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	self.navigationView = [[JDONavigationView alloc] init];
    [_navigationView addBackButtonWithTarget:self.viewDeckController action:@selector(backToConvenienceList)];
    [_navigationView setTitle:self.title];
    [self.view addSubview:_navigationView];
    
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)]; // 去掉导航栏和工具栏
    [self.webView makeTransparentAndRemoveShadow];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = true;
    [self.view addSubview:_webView];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void) loadWebView{
    [[JDOJsonClient sharedClient] getPath:CONVENIENCE_SERVICE parameters:@{@"channelid":self.channelid} success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)backToConvenienceList
{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}


// 在键盘事件的通知中获得以下参数，用来同步视图动画和键盘动画
CGRect endFrame;
NSTimeInterval timeInterval;

- (void)writeReviewView{
    
    [self.view pushView:_reviewPanel process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        [_textField becomeFirstResponder];
        _isKeyboardShowing = true;
        *_startFrame = CGRectMake(0, App_Height, 320, Textfield_Height+5);
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
    
    if( _isKeyboardShowing == false){
        endFrame = CGRectMake(0, keyboardTop-Textfield_Height, 320, Textfield_Height+5);// +5是为了去掉输入框与键盘间的空隙
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [animationDurationValue getValue:&timeInterval];
    }else{
        _reviewPanel.frame = CGRectMake(0, keyboardTop-Textfield_Height, 320, Textfield_Height+5);
    }
}

- (void)hideReviewView{
    [_textField resignFirstResponder];
    _isKeyboardShowing = false;
    [_reviewPanel popView:self.view process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        *_startFrame = _reviewPanel.frame;
        *_endFrame = CGRectMake(0, App_Height, 320, Textfield_Height+5);
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

#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return true;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

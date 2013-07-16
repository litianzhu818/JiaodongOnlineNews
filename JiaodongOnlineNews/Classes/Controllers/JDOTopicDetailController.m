//
//  JDOTopicDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOTopicDetailController.h"
#import "UIWebView+RemoveShadow.h"
#import "JDOTopicModel.h"
#import "JDOWebClient.h"
#import "JDOTopicDetailModel.h"
#import "JDOCenterViewController.h"
#import "WebViewJavascriptBridge_iOS.h"
#import "JDOReviewListController.h"
#import "UIDevice+IdentifierAddition.h"

@interface JDOTopicDetailController ()

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;

@end

@implementation JDOTopicDetailController

- (id)initWithTopicModel:(JDOTopicModel *)topicModel pController:(JDOTopicViewController *)pController{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.topicModel = topicModel;
        self.pController = pController;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)loadView{
    [super loadView];
    // 内容
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
    // 工具栏
    NSArray *toolbarBtnConfig = @[
                                  [NSNumber numberWithInt:ToolBarButtonReview],
                                  [NSNumber numberWithInt:ToolBarButtonShare],
                                  [NSNumber numberWithInt:ToolBarButtonFont],
                                  [NSNumber numberWithInt:ToolBarButtonCollect]
                                  ];
    _toolbar = [[JDOToolBar alloc] initWithModel:self.topicModel parentController:self typeConfig:toolbarBtnConfig widthConfig:nil frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];// 背景有透明渐变,高度是56不是44
    [self.view addSubview:_toolbar];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44-_toolbar.height)]; // 去掉导航栏和工具栏
    [self.webView makeTransparentAndRemoveShadow];
//    self.webView.delegate = self;
    self.webView.scalesPageToFit = true;
    [self.view addSubview:_webView];
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
    self.statusView.delegate = self;
    [self.view addSubview:self.statusView];
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadWebView];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadWebView];
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.webView.hidden = false;
    }else{
        self.webView.hidden = true;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self buildWebViewJavascriptBridge];
    [self loadWebView];
    
    _toolbar.bridge = self.bridge;
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.toolbar action:@selector(hideReviewView)];
    _blackMask = self.view.blackMask;
    [_blackMask addGestureRecognizer:self.closeReviewGesture];
}

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToListView)];
    [self.navigationView setTitle:@"每日一题"];
    [self.navigationView addRightButtonImage:@"top_navigation_review" highlightImage:@"top_navigation_review" target:self action:@selector(showReviewList)];
}

- (void) backToListView{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] orientation:JDOTransitionToRight animated:true complete:^{
        [_pController returnFromDetail];
    }];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [self setWebView:nil];
    [self setToolbar:nil];
    [self setStatusView:nil];
    
    [_blackMask removeGestureRecognizer:self.closeReviewGesture];
}

- (void) showReviewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithType:JDOReviewTypeNews params:@{@"aid":self.topicModel.id,@"deviceId":[[UIDevice currentDevice] uniqueDeviceIdentifier]}];
    [centerViewController pushViewController:reviewController animated:true];
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
#warning 若有缓存可以从缓存读取,话题涉及到动态的投票数量,是否缓存有待考虑
    if (false /*有缓存*/) {
        [self setCurrentState:ViewStatusLogo];
    }else if( ![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
    }else{
        [self setCurrentState:ViewStatusLoading];
        [[JDOJsonClient sharedClient] getPath:TOPIC_DETAIL_SERVICE parameters:@{@"aid":self.topicModel.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject isKindOfClass:[NSArray class]] && [(NSArray *)responseObject count]==0){
                // 新闻不存在
                [self setCurrentState:ViewStatusRetry];
            }else if([responseObject isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary *dict = [responseObject mutableCopy];
                [dict setObject:self.topicModel.id forKey:@"id"];
                self.topicModel.tinyurl = [responseObject objectForKey:@"tinyurl"];
                
                NSString *mergedHTML = [JDOTopicDetailModel mergeToHTMLTemplateFromDictionary:dict];
                NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
                [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
            }else{
                [self setCurrentState:ViewStatusRetry];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self setCurrentState:ViewStatusRetry];
        }];
    }
}

#pragma mark - Webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self setCurrentState:ViewStatusNormal];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self setCurrentState:ViewStatusRetry]; 
}
@end

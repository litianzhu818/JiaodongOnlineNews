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

@interface JDONewsDetailController ()

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

- (void)loadView{
    [super loadView];
    JDONavigationView *navigationView = [[JDONavigationView alloc] init];
    [self.view addSubview:navigationView];
    [navigationView addBackButtonWithTarget:self action:@selector(backToViewList)];
    [navigationView setTitle:@"新闻详情"];
    [navigationView addCustomButtonWithTarget:self action:@selector(backToViewList)];
    
    self.view.backgroundColor = [JDOCommonUtil colorFromString:@"f6f6f6"];// 与html的body背景色相同
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, 460-44)];
    [self.webView makeTransparentAndRemoveShadow];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = true;
    [self.view addSubview:_webView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 460-44)];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.3];
    [self.view addSubview:view];
    
    self.activityIndicationView = [[UIActivityIndicatorView alloc] init];
    self.activityIndicationView.center = self.webView.center;
    self.activityIndicationView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:_activityIndicationView];
    
}

- (void) backToViewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.tag = 101;
    [[JDOJsonClient sharedClient] getPath:NEWS_DETAIL_SERVICE parameters:@{@"aid":self.newsModel.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]] && [(NSArray *)responseObject count]==0){
            // 新闻不存在
        }else if([responseObject isKindOfClass:[NSDictionary class]]){
//            JDONewsDetailModel *detailModel = [(NSDictionary *)responseObject jsonDictionaryToModel:[JDONewsDetailModel class]];
#warning 必须保证webView不能横向滚动，否者pan手势不起作用
            NSString *mergedHTML = [JDONewsDetailModel mergeToHTMLTemplateFromDictionary:responseObject];
            [self.webView loadHTMLString:mergedHTML baseURL:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [self.activityIndicationView startAnimating];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning");
}

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

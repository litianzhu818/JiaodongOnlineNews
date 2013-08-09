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

@interface JDOConvenienceItemController ()

@end  

@implementation JDOConvenienceItemController

- (id)initWithService:(NSString *)service params:(NSDictionary *)params title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.service = service;
        self.params = params;
        self.navTitle = title;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)]; // 去掉导航栏和工具栏
    [self.webView makeTransparentAndRemoveShadow];
    self.webView.delegate = self;
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

#warning 检查所有有导航栏的界面navigationView添加的位置
- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToParent)];
    [self.navigationView setTitle:self.navTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadWebView];
}

-(void)viewDidUnload{
    [super viewDidUnload];
}

- (void) saveDetailToLocalCache:(NSDictionary *) params{
    NSString *cacheFilePath = [[SharedAppDelegate convenienceCachePath] stringByAppendingPathComponent:[@"Convenience_" stringByAppendingString:[params objectForKey:@"id"]]];
    [NSKeyedArchiver archiveRootObject:params toFile:cacheFilePath];
}

- (id) readDetailFromLocalCache{
    NSDictionary *detailModel = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath([@"JDOCache/ConvenienceCache" stringByAppendingPathComponent:[@"Convenience_" stringByAppendingString:[self.params objectForKey:@"aid"]]])];
    return detailModel;
}

- (void) loadWebView{
    if( ![Reachability isEnableNetwork]){
        NSDictionary *detailModel = [self readDetailFromLocalCache];
        if (detailModel) {//网络不连通，但是有缓存
            NSString *mergedHTML = [JDONewsDetailModel mergeToHTMLTemplateFromDictionary:detailModel];
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
        } else {
            [self setCurrentState:ViewStatusNoNetwork];
        }
        return;
    }
    [self setCurrentState:ViewStatusLoading];
    [[JDOJsonClient sharedClient] getPath:self.service parameters:self.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]] && [(NSArray *)responseObject count]==0){
            // 新闻不存在
        }else if([responseObject isKindOfClass:[NSDictionary class]]){
            NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
            if (self.deletetitle) {
                [response removeObjectForKey:@"title"];
                [response removeObjectForKey:@"source"];
                [response removeObjectForKey:@"addtime"];
            }
            [self saveDetailToLocalCache:response];
            //            JDONewsDetailModel *detailModel = [(NSDictionary *)responseObject jsonDictionaryToModel:[JDONewsDetailModel class]];
            NSString *mergedHTML = [JDONewsDetailModel mergeToHTMLTemplateFromDictionary:response];
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)backToParent
{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count -2] animated:true];
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

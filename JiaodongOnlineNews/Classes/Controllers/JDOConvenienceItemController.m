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
#import "JDOLeftViewController.h"
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

// 所有有导航栏的界面navigationView都应该在视图层级的最后添加或者bringToFront
- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToParent)];
    [self.navigationView setTitle:self.navTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.toolbar removeFromSuperview];
    // 重设webView的大小，加上toolbar的高度
    CGRect f = self.webView.frame;
    f.size.height += 44;
    self.webView.frame = f;
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
    [[JDOJsonClient sharedClient] getPath:self.service parameters:self.params success:^(AFHTTPRequestOperation *operation, id object) {
        id responseObject = [(NSDictionary *)object objectForKey:@"data"];
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
            NSString *mergedHTML = [JDONewsDetailModel mergeToHTMLTemplateFromDictionary:[self replaceUrlAndAsyncLoadImage:response]];
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)backToParent
{
    if ([self.navTitle isEqualToString:@"烟台天气"]) {
        [self.stackContainer popViewController:0];
    } else {
        JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
        [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count -2] animated:true];
    }
}

@end

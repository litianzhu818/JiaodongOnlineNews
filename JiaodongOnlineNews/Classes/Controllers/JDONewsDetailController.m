//
//  JDONewsDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsDetailController.h"
#import "JDONewsModel.h"
#import "JDOWebClient.h"
#import "JDONewsDetailModel.h"
#import "JDOCenterViewController.h"
#import "JDOReviewListController.h"
#import "UIDevice+IdentifierAddition.h"
#import "DCKeyValueObjectMapping.h"
#import "JDOCommonUtil.h"
#import "JDORightViewController.h"
#import <AdSupport/AdSupport.h>

@interface JDONewsDetailController ()

@end

@implementation JDONewsDetailController

NSDate *modifyTime;

- (id)initWithNewsModel:(JDONewsModel *)newsModel{
    return [self initWithNewsModel:newsModel Collect:false];
}

- (id)initWithNewsModel:(JDONewsModel *)newsModel Collect:(BOOL)isCollect isAdv:(BOOL)isAdv{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.isAdv = isAdv;
        self.newsModel = newsModel;
        modifyTime = [NSDate dateWithTimeIntervalSince1970:0];
        self.isCollect = isCollect;
        self.model = self.newsModel;
    }
    return self;
}

- (id)initWithNewsModel:(JDONewsModel *)newsModel Collect:(BOOL)isCollect{
    return [self initWithNewsModel:newsModel Collect:isCollect isAdv:NO];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

#pragma mark - Navigation

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToListView)];
    if (self.isAdv) {
        [self.navigationView setTitle:@"广告详情"];
    } else {
        [self.navigationView setTitle:@"新闻详情"];
    }
    [self.navigationView addRightButtonImage:@"top_navigation_review" highlightImage:@"top_navigation_review" target:self action:@selector(showReviewList)];
}

- (void) showReviewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithType:JDOReviewTypeNews params:@{@"aid":self.newsModel.id,@"deviceId":JDOGetUUID()}];
    reviewController.model = self.newsModel;
    [centerViewController pushViewController:reviewController animated:true];
}

- (void) saveNewsDetailToLocalCache:(NSDictionary *) newsDetail{
    NSString *cacheFilePath = [[SharedAppDelegate newsDetailCachePath] stringByAppendingPathComponent:[@"NewsDetail_" stringByAppendingString:[newsDetail objectForKey:@"id"]]];
    [NSKeyedArchiver archiveRootObject:newsDetail toFile:cacheFilePath];
}

- (id) readNewsDetailFromLocalCache{
    NSDictionary *detailModel = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath([@"JDOCache/NewsDetailCache" stringByAppendingPathComponent:[@"NewsDetail_" stringByAppendingString:self.newsModel.id]])];
    return detailModel;
}

- (NSDictionary *) getParam{
    if(self.isAdv){
        return @{@"aid":self.newsModel.id};
    } else {
        return @{@"aid":self.newsModel.id,@"advCid":@"39",@"advLimit":@"1"};
    }
}

- (void) loadWebView{
    NSMutableDictionary *detailModel = [self readNewsDetailFromLocalCache];
    if (self.isPushNotification) {  // 推送消息忽略缓存
        detailModel = nil;
    } else {
        modifyTime = [JDOCommonUtil formatString:self.newsModel.modifytime withFormatter:DateFormatYMDHMS];
        NSDate *modifyTime_db =[JDOCommonUtil formatString:[detailModel objectForKey:@"modifytime"] withFormatter:DateFormatYMDHMS];
        if ([modifyTime compare:modifyTime_db] != NSOrderedSame) {//服务器修改时间与本地记录的不同，忽略缓存
            detailModel = nil;
        }
    }
    
    if (detailModel /*有缓存*/) {
        [self setCurrentState:ViewStatusLoading];
        // 设置url短地址
        self.newsModel.tinyurl = [detailModel objectForKey:@"tinyurl"];
        //[self.navigationView setRightBtnCount:@"555"];
        [self.navigationView setRightBtnCount:[detailModel objectForKey:@"commentCount"]];
        if (self.isAdv) {//广告不显示来源和添加时间
            [detailModel removeObjectForKey:@"addtime"];
            [detailModel removeObjectForKey:@"source"];
        }
        NSString *mergedHTML = [JDONewsDetailModel mergeToHTMLTemplateFromDictionary:[self replaceUrlAndAsyncLoadImage:detailModel]];
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
    }else if( ![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
    }else{
        [self setCurrentState:ViewStatusLoading];
        [[JDOJsonClient sharedClient] getPath:NEWS_DETAIL_SERVICE parameters:[self getParam] success:^(AFHTTPRequestOperation *operation, id object) {
            id responseObject = [((NSDictionary *)object) objectForKey:@"data"];
            if([responseObject isKindOfClass:[NSArray class]] && [(NSArray *)responseObject count]==0){
                // 新闻不存在
                [self setCurrentState:ViewStatusRetry];
            }else if([responseObject isKindOfClass:[NSDictionary class]]){
                [self saveNewsDetailToLocalCache:responseObject];
                NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
                // 设置url短地址
                self.newsModel.tinyurl = [responseObject objectForKey:@"tinyurl"];
                
                // 推送新闻不是从列表导航进入,所以newsModel中只存在id,其他JDOToolbarMoedl需要的信息都要从detail的信息中复制
                if (self.isPushNotification) {
                    self.newsModel.title = [responseObject objectForKey:@"title"];
                    self.newsModel.summary = [responseObject objectForKey:@"summary"];
                    self.newsModel.mpic =  [responseObject objectForKey:@"mpic"];
                }
                
                if (self.isAdv) {
                    [mdic removeObjectForKey:@"addtime"];
                    [mdic removeObjectForKey:@"source"];
                    self.newsModel.title = @"推广";
                    self.newsModel.summary = [responseObject objectForKey:@"title"];
                }
                [self.navigationView setRightBtnCount:[responseObject objectForKey:@"commentCount"]];
                NSString *mergedHTML = [JDONewsDetailModel mergeToHTMLTemplateFromDictionary:[self replaceUrlAndAsyncLoadImage:mdic]];
                NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
                [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
            }else{
                // 返回结构不是json结构
                [self setCurrentState:ViewStatusRetry];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self setCurrentState:ViewStatusRetry];
        }];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [super webViewDidFinishLoad:webView];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"JDO_Introduce_NewsDetail"] || Debug_Guide_Introduce) {
        UIView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height)];
        backgroundView.userInteractionEnabled = true;
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7f];
        [backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(introduceViewClicked:)]];
        backgroundView.alpha = 0;
        UIImageView *introduceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Is_iOS7?20:0, 320, [UIScreen mainScreen].applicationFrame.size.height)];
        introduceView.image = [UIImage imageNamed:@"Introduce_NewsDetail"];
        [backgroundView addSubview:introduceView];
        [self.view addSubview:backgroundView];
        [UIView animateWithDuration:0.4 animations:^{
            backgroundView.alpha = 1;
        }];
    }
}

- (void) buildWebViewJavascriptBridge{
    [super buildWebViewJavascriptBridge];
    [super.bridge registerHandler:@"toRelative" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *newsid = [(NSDictionary *)data valueForKey:@"newsid"];
        JDONewsModel *newsModel = [[JDONewsModel alloc] init];
        newsModel.id = newsid;
        JDONewsDetailController *newsDetailController = [[JDONewsDetailController alloc] initWithNewsModel:newsModel];
        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
        [centerController pushViewController:newsDetailController animated:true];
        responseCallback(@"joinin");
    }];
}

- (void) introduceViewClicked:(UITapGestureRecognizer *)gesture{
    [UIView animateWithDuration:0.4 animations:^{
        gesture.view.alpha = 0;
    } completion:^(BOOL finished) {
        [gesture.view removeFromSuperview];
        [gesture.view removeGestureRecognizer:gesture];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"JDO_Introduce_NewsDetail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

@end

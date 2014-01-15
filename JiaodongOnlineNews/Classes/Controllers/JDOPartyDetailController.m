//
//  JDONewsDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPartyDetailController.h"
#import "JDOPartyJoinController.h"
#import "UIWebView+RemoveShadow.h"
#import "JDOPartyModel.h"
#import "JDOPartyDetailModel.h"
#import "JDONewsDetailModel.h"
#import "JDOWebModel.h"

@interface JDOPartyDetailController ()

@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;

@end

@implementation JDOPartyDetailController

NSArray *imageUrls;

- (id)initWithPartyModel:(JDOPartyModel *)partyModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.partyModel = partyModel;
        self.model = [[JDOWebModel alloc] initWithId:partyModel.id andTitle:partyModel.title andImageurl:partyModel.mpic andSummary:partyModel.summary andTinyurl:partyModel.tinyurl];
    }
    return self;
}

- (NSArray *)setupToolBarBtnConfig {
    NSArray *toolbarBtnConfig = @[
                                  [NSNumber numberWithInt:ToolBarButtonShare],
                                  [NSNumber numberWithInt:ToolBarButtonFont]
                                  ];
    return toolbarBtnConfig;
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

- (void) buildWebViewJavascriptBridge{
    [super buildWebViewJavascriptBridge];
    [super.bridge registerHandler:@"joinInParty" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *joinBtnStr = [(NSDictionary *)data valueForKey:@"joinBtnStr"];
        if ([joinBtnStr isEqualToString:@"我要报名"]) {
            [[JDOJsonClient sharedClient] getPath:PARTY_JOIN_SERVICE parameters:@{@"aid":self.partyModel.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSMutableDictionary *partyJoin = [[NSMutableDictionary alloc] initWithDictionary:[(NSMutableDictionary *)responseObject objectForKey:@"data" ]];
                [partyJoin setValue:self.partyModel.id forKey:@"id"];
                JDOPartyJoinController *partyJoinController = [[JDOPartyJoinController alloc] initWithPartyJoin:partyJoin];
                JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
                [centerController pushViewController:partyJoinController animated:true];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        responseCallback(@"joinin");
    }];
}

#pragma mark - Navigation

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToViewList)];
    [self.navigationView setTitle:@"精彩活动"];
}

#pragma mark - Load WebView

- (void) saveNewsDetailToLocalCache:(NSDictionary *) partyDetail{
    NSString *cacheFilePath = [[SharedAppDelegate partyDetailCachePath] stringByAppendingPathComponent:[@"PartyDetail_" stringByAppendingString:[partyDetail objectForKey:@"id"]]];
    [NSKeyedArchiver archiveRootObject:partyDetail toFile:cacheFilePath];
}

- (id) readNewsDetailFromLocalCache{
    NSDictionary *detailModel = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath([@"JDOCache/PartyDetailCache" stringByAppendingPathComponent:[@"PartyDetail_" stringByAppendingString:self.partyModel.id]])];
    return detailModel;
}

- (void) loadWebView{
    NSMutableDictionary *detailModel = [self readNewsDetailFromLocalCache];
    if (detailModel /*有缓存*/) {
        [self setCurrentState:ViewStatusLoading];
        // 设置url短地址
        self.model.tinyurl = [detailModel objectForKey:@"tinyurl"];
        if (self.partyModel.showMore) {
            [detailModel setObject:@"1" forKey:@"showMore"];
        } else {
            [detailModel setObject:@"0" forKey:@"showMore"];
        }
        NSString *mergedHTML = [JDOPartyDetailModel mergeToHTMLTemplateFromDictionary:[self replaceUrlAndAsyncLoadImage:detailModel]];
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
    }else if( ![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
    }else{
        [self setCurrentState:ViewStatusLoading];
        [[JDOJsonClient sharedClient] getPath:PARTY_DETAIL_SERVICE parameters:@{@"aid":self.model.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject isKindOfClass:[NSArray class]] && [(NSArray *)responseObject count]==0){
                // 新闻不存在
                [self setCurrentState:ViewStatusRetry];
            }else if([responseObject isKindOfClass:[NSDictionary class]]){
                NSMutableDictionary *dic = [[responseObject objectForKey:@"data"] mutableCopy];
                [self saveNewsDetailToLocalCache:dic];
                // 设置url短地址
                self.model.tinyurl = [dic objectForKey:@"tinyurl"];
                if (self.partyModel.showMore) {
                    [dic setObject:@"1" forKey:@"showMore"];
                } else {
                    [dic setObject:@"0" forKey:@"showMore"];
                }
                NSString *mergedHTML = [JDOPartyDetailModel mergeToHTMLTemplateFromDictionary:[self replaceUrlAndAsyncLoadImage:dic]];
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

@end

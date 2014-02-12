//
//  JDOTopicDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOTopicDetailController.h"
#import "JDOTopicModel.h"
#import "JDOWebClient.h"
#import "JDOTopicDetailModel.h"
#import "JDOCenterViewController.h"
#import "WebViewJavascriptBridge_iOS.h"
#import "JDOReviewListController.h"
#import "UIDevice+IdentifierAddition.h"
#import "JDORightViewController.h"
#import <AdSupport/AdSupport.h>

@interface JDOTopicDetailController ()

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;

@end

@implementation JDOTopicDetailController

NSArray *imageUrls;

- (id)initWithTopicModel:(JDOTopicModel *)topicModel pController:(JDOTopicViewController *)pController{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.topicModel = topicModel;
        self.pController = pController;
        self.model = self.topicModel;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToListView)];
    [self.navigationView setTitle:@"每日一题"];
    [self.navigationView addRightButtonImage:@"top_navigation_review" highlightImage:@"top_navigation_review" target:self action:@selector(showReviewList)];
}

- (void) backToListView{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count -2] orientation:JDOTransitionToRight animated:true complete:^{
        [_pController returnFromDetail];
    }];
}

- (void) showReviewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithType:JDOReviewTypeNews params:@{@"aid":self.topicModel.id,@"deviceId":JDOGetUUID()}];
    reviewController.model = self.topicModel;
    [centerViewController pushViewController:reviewController animated:true];
}

- (void) saveTopicDetailToLocalCache:(NSDictionary *) topicDetail{
    NSString *cacheFilePath = [[SharedAppDelegate topicDetailCachePath] stringByAppendingPathComponent:[@"TopicDetail_" stringByAppendingString:[topicDetail objectForKey:@"id"]]];
    [NSKeyedArchiver archiveRootObject:topicDetail toFile:cacheFilePath];
}

- (id) readTopicDetailFromLocalCache{
    NSDictionary *topicModel = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath([@"JDOCache/TopicDetailCache" stringByAppendingPathComponent:[@"TopicDetail_" stringByAppendingString:self.topicModel.id]])];
    return topicModel;
}

- (void) loadWebView{
#warning 若有缓存可以从缓存读取,话题涉及到动态的投票数量,是否缓存有待考虑
    NSMutableDictionary *topicModel = [self readTopicDetailFromLocalCache];
    if (topicModel && ![Reachability isEnableNetwork]/*无网络但是有缓存*/) {
        [self setCurrentState:ViewStatusLoading];
        self.topicModel.tinyurl = [topicModel objectForKey:@"tinyurl"];
        [self.navigationView setRightBtnCount:[topicModel objectForKey:@"commentCount"]];
        if (self.topicModel.showMore) {
            [topicModel setObject:@"1" forKey:@"showMore"];
        } else {
            [topicModel setObject:@"0" forKey:@"showMore"];
        }
        NSString *mergedHTML = [JDOTopicDetailModel mergeToHTMLTemplateFromDictionary:[self replaceUrlAndAsyncLoadImage:topicModel]];
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        [self.webView loadHTMLString:mergedHTML baseURL:[NSURL fileURLWithPath:bundlePath isDirectory:true]];
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
                // 从新闻列表导航进来没有评论数，获取评论数需要sum，为防止性能问题暂不添加
                if(self.topicModel.follownums == nil){
                    [dict setObject:@"0" forKey:@"commentCount"];
                }else{
                    [dict setObject:self.topicModel.follownums forKey:@"commentCount"];
                }
                
                [self saveTopicDetailToLocalCache:dict];
                self.topicModel.tinyurl = [dict objectForKey:@"tinyurl"];
                [self.navigationView setRightBtnCount:[dict objectForKey:@"commentCount"]];
                if (self.topicModel.showMore) {
                    [dict setObject:@"1" forKey:@"showMore"];
                } else {
                    [dict setObject:@"0" forKey:@"showMore"];
                }
                NSString *mergedHTML = [JDOTopicDetailModel mergeToHTMLTemplateFromDictionary:[self replaceUrlAndAsyncLoadImage:dict]];
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

@end

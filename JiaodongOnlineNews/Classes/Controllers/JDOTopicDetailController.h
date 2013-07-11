//
//  JDOTopicDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOToolBar.h"
#import "JDOTopicViewController.h"

@class JDOTopicModel;

@interface JDOTopicDetailController : JDONavigationController <UIWebViewDelegate,UITextViewDelegate>

@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) JDOTopicModel *topicModel;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicationView;
@property (nonatomic,strong) JDOToolBar *toolbar;
@property (nonatomic,strong) JDOTopicViewController *pController;

- (id)initWithTopicModel:(JDOTopicModel *)topicModel pController:(JDOTopicViewController *)pController;

@end
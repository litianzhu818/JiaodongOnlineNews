//
//  JDONewsDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOToolBar.h"

@class JDONewsModel;

@interface JDONewsDetailController : JDONavigationController <UIWebViewDelegate,UITextViewDelegate,JDOStatusView,JDOStatusViewDelegate,SDWebImageManagerDelegate,SDWebImageStoreDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) JDONewsModel *newsModel;
@property (nonatomic,strong) JDOToolBar *toolbar;
@property (nonatomic,assign) BOOL isCollect;//判断是否是从收藏列表里进入，如果是的话返回右菜单
- (id)initWithNewsModel:(JDONewsModel *)newsModel;
- (id)initWithNewsModel:(JDONewsModel *)newsModel Collect:(BOOL)isCollect;
@end

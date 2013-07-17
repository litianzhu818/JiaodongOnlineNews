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

@interface JDONewsDetailController : JDONavigationController <UIWebViewDelegate,UITextViewDelegate,JDOStatusView,JDOStatusViewDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) JDONewsModel *newsModel;
@property (nonatomic,strong) JDOToolBar *toolbar;
@property (nonatomic,strong) NSString *title;

- (id)initWithNewsModel:(JDONewsModel *)newsModel;

@end

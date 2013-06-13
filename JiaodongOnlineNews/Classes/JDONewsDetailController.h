//
//  JDONewsDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@class JDONewsModel;

@interface JDONewsDetailController : UIViewController <JDONavigationView,UIWebViewDelegate,UITextViewDelegate,HPGrowingTextViewDelegate>

@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) JDONewsModel *newsModel;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicationView;
@property (strong,nonatomic) JDONavigationView *navigationView;

- (id)initWithNewsModel:(JDONewsModel *)newsModel;

@end

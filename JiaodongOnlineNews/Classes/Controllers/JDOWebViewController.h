//
//  JDOWebControllerViewController.h
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-12-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"
#import "WebViewJavascriptBridge_iOS.h"
#import "JDOToolBar.h"
#import "JDOToolbarModel.h"

@interface JDOWebViewController : JDONavigationController<UIWebViewDelegate,JDOStatusView,JDOStatusViewDelegate,SDWebImageManagerDelegate,SDWebImageStoreDelegate,JDOShareTargetDelegate>
@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) JDOToolBar *toolbar;
@property (nonatomic,strong) id<JDOToolbarModel> model;
@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (nonatomic) BOOL isAdv;


- (void) buildWebViewJavascriptBridge;
- (id) replaceUrlAndAsyncLoadImage:(NSDictionary *) dictionary;
- (void) backToListView;
@end

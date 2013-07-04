//
//  JDOBusDetailViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-3.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge_iOS.h"
#import "JDOBusLIstViewController.h"

@interface JDOBusDetailViewController : JDONavigationController <UIWebViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) JDOBusLIstViewController *back;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicationView;
@property (strong,nonatomic) NSString *aid;

@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) UIView *reviewPanel;
@property (strong, nonatomic) UITextField *textField;
@property (assign, nonatomic) BOOL isKeyboardShowing;

@end

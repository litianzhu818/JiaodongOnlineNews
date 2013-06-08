//
//  JDOConvenienceItemController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge_iOS.h"

@interface JDOConvenienceItemController : UIViewController <JDONavigationView,UIWebViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) UIWebView *webView;
@property (strong,nonatomic) JDONavigationView *navigationView;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicationView;
@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *channelid;

@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) UIView *reviewPanel;
@property (strong, nonatomic) UITextField *textField;
@property (assign, nonatomic) BOOL isKeyboardShowing;

-(void)backToConvenienceList;

@end

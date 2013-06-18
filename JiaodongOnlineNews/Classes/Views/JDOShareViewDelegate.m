//
//  JDOShareViewDelegate.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-17.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOShareViewDelegate.h"
#import <ShareSDK/ShareSDK.h>

@interface JDOShareViewDelegate ()

@property (strong, nonatomic) UIButton *backBtn;

@end

static JDOShareViewDelegate* sharedDelegate;

@implementation JDOShareViewDelegate{
    void (^_backBlock)();
    void (^_completeBlock)();
    BOOL viewClosedByBack;
}

+ (JDOShareViewDelegate*) sharedDelegate{
    if(sharedDelegate == nil){
        sharedDelegate = [[JDOShareViewDelegate alloc] initWithBackBlock:nil completeBlock:nil];
    }
    return sharedDelegate;
}

- (id) initWithBackBlock:(void (^)()) backBlock completeBlock:(void (^)()) completeBlock{
    if(self = [super init]){
        _backBlock = backBlock;
        _completeBlock = completeBlock;
    }
    return self;
}

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType{
    viewClosedByBack = false;
    [viewController.navigationController setNavigationBarHidden:true];
    // 有toolbar的情况下,授权视图索引可能为1，否则为0
    UIView *authView = (UIView *)[[viewController.view subviews] lastObject];
    //    NSAssert([authView isKindOfClass:NSClassFromString(@"SSSinaWeiboAuthView")], @"authView不是SSSinaWeiboAuthView");
    if([viewController.view subviews].count >1){    // 有工具栏
        authView.frame = CGRectMake(0, 44, 320, App_Height-44-40);
    }else{
        authView.frame = CGRectMake(0, 44, 320, App_Height-44);
    }
    
    _backBtn = (UIButton *)[[[[viewController.navigationController.navigationBar items] objectAtIndex:0] leftBarButtonItem] customView];
    JDONavigationView *navigationView = [[JDONavigationView alloc] init];
    [navigationView addBackButtonWithTarget:self action:@selector(backToParent)];
    [navigationView setTitle:[ShareSDK getClientNameWithType:shareType]];
    [viewController.view addSubview:navigationView];
}

- (void)viewOnWillDismiss:(UIViewController *)viewController shareType:(ShareType)shareType{
    if(viewClosedByBack == false){ //授权完成返回
        if(_completeBlock) _completeBlock();
    }
}

- (void) backToParent{
    viewClosedByBack = true;
    [_backBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    if(_backBlock) _backBlock();
}

@end

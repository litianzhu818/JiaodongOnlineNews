//
//  JDOStatusView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ViewStatusNormal = 0,   //显示正常视图
    ViewStatusNoNetwork,    //网络可不用
    ViewStatusLogo,         //初始化页面(网站Logo)
    ViewStatusLoading,      //视图加载中
    ViewStatusRetry,        //服务器错误,点击重试
} ViewStatusType;   //需要从网络加载的视图的几种状态变化

@interface JDOStatusView : UIView

@property (nonatomic,strong) UIImageView *noNetWorkView;
@property (nonatomic,strong) UIImageView *logoView;
@property (nonatomic,strong) UIImageView *retryView;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic,assign) ViewStatusType status;

- (void) setReloadTarget:(id)target selector:(SEL)selector;

@end

@protocol JDOStatusView

@required
@property (strong,nonatomic) JDOStatusView *statusView;
- (void) setCurrentState:(ViewStatusType)status;

@end

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

@protocol JDOStatusViewDelegate;

@interface JDOStatusView : UIView
#warning 背景图在不同高度下容易被压缩，可以考虑用同一个背景图，中间显示的文字通过程序添加
@property (nonatomic,strong) UIImageView *noNetWorkView;
@property (nonatomic,strong) UIImageView *logoView;
@property (nonatomic,strong) UIImageView *retryView;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,assign) id<JDOStatusViewDelegate> delegate;

@end

@protocol JDOStatusView <NSObject>

@required
@property (strong,nonatomic) JDOStatusView *statusView;
- (void) setCurrentState:(ViewStatusType)status;

@end

@protocol JDOStatusViewDelegate <NSObject>

@optional
- (void) onRetryClicked:(JDOStatusView *) statusView;
- (void) onNoNetworkClicked:(JDOStatusView *) statusView;

@end



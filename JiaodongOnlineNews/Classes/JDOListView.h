//
//  JDOListView.h
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDONewsCategoryInfo.h"
typedef enum {
    NewsViewStatusNormal = 0,   //显示新闻列表
    NewsViewStatusNoNetwork,    //网络可不用
    NewsViewStatusLogo,         //初始化页面
    NewsViewStatusLoading,      //新闻列表加载中
    NewsViewStatusRetry,        //服务器错误,点击重试
} NewsViewStatus;   //新闻页面的几种状态变化
@interface JDOListView : UIView
- (id)initWithFrame:(CGRect)frame serviceName:(NSString*)serviceName modelClass:(Class)modelClass;

@property (nonatomic,assign) NewsViewStatus status;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *noNetWorkView;
@property (nonatomic,strong) UIImageView *logoView;
@property (nonatomic,strong) UIImageView *retryView;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,strong) Class modelClass;
- (void)loadDataFromNetwork;
@end

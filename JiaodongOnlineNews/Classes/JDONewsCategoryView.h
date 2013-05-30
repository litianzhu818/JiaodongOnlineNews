//
//  JDONewsTableView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-28.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"

typedef enum {
    NewsCategoryLocal = 0,      //本地
    NewsCategoryImportant,      //要闻
    NewsCategorySocial,         //社会
    NewsCategoryEntertainment,  //娱乐
    NewsCategorySport           //体育
} NewsCategory;

typedef enum {
    NewsViewStatusNormal = 0,   //显示新闻列表
    NewsViewStatusNoNetwork,    //网络可不用
    NewsViewStatusLogo,         //初始化页面
    NewsViewStatusLoading,      //新闻列表加载中
    NewsViewStatusRetry,        //服务器错误,点击重试
} NewsViewStatus;   //新闻页面的几种状态变化


@interface JDONewsCategoryView : NIPageView <UITableViewDelegate, UITableViewDataSource>

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier category:(NewsCategory)category;

@property (nonatomic,assign) NewsCategory category;
@property (nonatomic,assign) NewsViewStatus status;
@property (nonatomic, readwrite, retain) UITableView *tableView;
@property (nonatomic, readwrite, retain) UIImageView *noNetWorkView;
@property (nonatomic, readwrite, retain) UIImageView *logoView;
@property (nonatomic, readwrite, retain) UIImageView *retryView;
@property (nonatomic, readwrite, retain) UIActivityIndicatorView *activityIndicator;

- (void) loadDataFromNetwork:(void (^)(BOOL finished))completion;

@end

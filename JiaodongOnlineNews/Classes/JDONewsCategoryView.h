//
//  JDONewsTableView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-28.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"
#import "JDONewsCategoryInfo.h"

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

typedef void(^LoadDataSuccessBlock)(NSArray *dataList);
typedef void(^LoadDataFailureBlock)(NSString *errorStr);


@interface JDONewsCategoryView : NIPageView <UITableViewDelegate, UITableViewDataSource>

- (id)initWithFrame:(CGRect)frame info:(JDONewsCategoryInfo *)info;

@property (nonatomic,assign) JDONewsCategoryInfo *info;
@property (nonatomic,assign) NewsViewStatus status;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *noNetWorkView;
@property (nonatomic,strong) UIImageView *logoView;
@property (nonatomic,strong) UIImageView *retryView;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic,strong) NSMutableArray *headArray;
@property (nonatomic,strong) NSMutableArray *listArray;

- (void)loadDataFromNetwork;
//- (void)loadHeadlineSuccess:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;
//- (void)loadNewsListSuccess:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

@end

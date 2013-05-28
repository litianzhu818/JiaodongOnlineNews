//
//  JDONewsTableView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-28.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"

typedef enum {
    NewsCategoryLocal = 0,
    NewsCategoryImportant,
    NewsCategorySocial,
    NewsCategoryEntertainment,
    NewsCategorySport
} NewsCategory;

typedef enum {
    NewsViewStatusNormal = 0,
    NewsViewStatusNoNetwork,
    NewsViewStatusLogo,
    NewsViewStatusLoading,
    NewsViewStatusRetry,
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

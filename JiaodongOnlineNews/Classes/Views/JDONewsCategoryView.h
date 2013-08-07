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

@protocol JDOStatusViewDelegate;

@interface JDONewsCategoryView : NIPageView <JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate>

- (id)initWithFrame:(CGRect)frame info:(JDONewsCategoryInfo *)info;

@property (nonatomic,assign) JDONewsCategoryInfo *info;
@property (nonatomic,strong) UITableView *tableView;


@property (nonatomic,strong) NSMutableArray *headArray;
@property (nonatomic,strong) NSMutableArray *listArray;

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;

@property (nonatomic,assign) BOOL isShowingLocalCache;

- (void)loadDataFromNetwork;

- (BOOL) readListFromLocalCache;

@end

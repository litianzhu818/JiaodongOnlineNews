//
//  JDOListViewController.h
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Finished_Label_Tag 112

@interface JDOListViewController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *modelClass;
@property (nonatomic,strong) NSMutableDictionary *listParam;

@property (nonatomic,assign) int currentPage;
@property (nonatomic,assign) int pageSize;
@property (nonatomic) BOOL isCacheToMemory;
@property (nonatomic, strong) NSString *cacheFileName;

@property (strong,nonatomic) UIImageView *noDataView;

- (id)initWithServiceName:(NSString*)serviceName modelClass:(NSString*)modelClass title:(NSString*)title params:(NSMutableDictionary *)listParam needRefreshControl:(BOOL)needRefreshControl;
- (void)loadDataFromNetwork;
- (void) refresh;
- (void) loadMore;
- (void) dataLoadFinished:(NSArray *)dataList;
- (void) setIsCacheToMemory:(BOOL)isCacheToMemory andCacheFileName:(NSString *)cacheFileName;

@end

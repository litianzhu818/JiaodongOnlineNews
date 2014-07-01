//
//  JDOVideoEPGList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-25.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//
#import "NimbusPagingScrollView.h"
#import "JDOVideoModel.h"
#import "JDOVideoEPG.h"

@protocol JDOStatusViewDelegate;

@interface JDOVideoEPGList : NIPageView <JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) JDOVideoModel *videoModel;
@property (nonatomic,assign) int selectedRow;

@property (nonatomic,assign) id<JDOVideoEPGDelegate> delegate;

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)reuseId;

- (void)loadDataFromNetwork;

@end

//
//  JDOVideoLiveList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"

@protocol JDOStatusViewDelegate;

@interface JDOVideoLiveList : NIPageView <JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (strong,nonatomic) UIView *rootView;

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)reuseId;

- (void)loadDataFromNetwork;

@end
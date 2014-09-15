//
//  JDOVideoLiveList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"
#import "JDOVideoLiveCell.h"

@protocol JDOStatusViewDelegate;

@interface JDOVideoLiveList : NIPageView <JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate,JDOVideoLiveDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *listArray;

- (id)initWithFrame:(CGRect)frame identifier:(NSString *)reuseId;

- (void)loadDataFromNetwork;

@end

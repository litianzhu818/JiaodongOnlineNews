//
//  JDOReportActivityList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-9-12.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"

@protocol JDOStatusViewDelegate;

@interface JDOReportActivityList : NIPageView <JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *listArray;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

- (void)loadDataFromNetwork;

@end

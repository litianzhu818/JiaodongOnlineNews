//
//  JDOLifeKnowledgeViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDONewsCategoryInfo.h"

@interface JDOLifeKnowledgeViewController : JDONavigationController <JDOStatusView,JDOStatusViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *reuseId;
@property (nonatomic,strong) NSString *channelid;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *listArray;

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;

@property (nonatomic,assign) BOOL isShowingLocalCache;

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

- (void)loadDataFromNetwork;

@end

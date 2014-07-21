//
//  JDOOnDemandController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-16.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOListViewController.h"
#import "JDOVideoChannelModel.h"

@interface JDOOnDemandController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate,UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (strong,nonatomic) UIImageView *noDataView;

-(id)initWithModel:(JDOVideoChannelModel *)model;

@end

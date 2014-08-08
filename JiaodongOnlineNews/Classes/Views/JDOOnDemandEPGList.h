//
//  JDOOnDemandEPGList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoOnDemandModel.h"
#import "JDOVideoEPG.h"
#import "JDOOnDemandPlayController.h"

@protocol JDOStatusViewDelegate;

@interface JDOOnDemandEPGList : UIView <JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) JDOOnDemandPlayController *player;
@property (nonatomic,strong) NSArray *models;
@property (nonatomic,assign) int selectedRow;

- (id)initWithFrame:(CGRect)frame models:(NSArray *)models;
- (void)loadDataFromNetwork;

@end

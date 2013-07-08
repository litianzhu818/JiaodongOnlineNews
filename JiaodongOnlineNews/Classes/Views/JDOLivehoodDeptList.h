//
//  JDOLivehoodDeptList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"

@class JDOLivehoodViewController;

@interface JDOLivehoodDeptList : NIPageView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) NSDictionary *info;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,assign) JDOLivehoodViewController *livehoodController;


- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info;
- (void)loadDataFromNetwork;

@end

//
//  JDONewsSpecialViewController.h
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 14-1-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDONewsSpecialModel.h"
@class JDONewsModel;
@interface JDONewsSpecialController : JDONavigationController<JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) JDONewsSpecialModel *model;
@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
-(id)initWithModel:(JDONewsSpecialModel *)model;
@end

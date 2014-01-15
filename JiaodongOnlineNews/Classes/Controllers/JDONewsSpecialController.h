//
//  JDONewsSpecialViewController.h
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 14-1-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDONewsSpecialModel.h"

@interface JDONewsSpecialController : JDONavigationController
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) JDONewsSpecialModel *model;
-(id)initWithModel:(JDONewsSpecialModel *)model;
@end

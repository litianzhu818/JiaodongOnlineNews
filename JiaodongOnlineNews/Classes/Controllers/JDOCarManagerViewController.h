//
//  JDOCarManagerViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-17.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"
#import "JDOViolationViewController.h"
#import "JDOAddCarViewController.h"

@interface JDOCarManagerViewController : JDONavigationController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *listview;
@property (nonatomic, strong) JDOViolationViewController *back;

- (void)onBackBtnClick;
- (void)onRightBtnClick;

@end

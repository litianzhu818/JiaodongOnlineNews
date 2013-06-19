//
//  JDOSettingViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-22.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDORightViewController.h"

@interface JDOSettingViewController : JDONavigationController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) JDORightViewController *rightController;

@end

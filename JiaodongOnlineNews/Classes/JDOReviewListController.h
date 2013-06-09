//
//  JDOReviewListController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOReviewListController : UIViewController<JDONavigationView,UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) JDONavigationView *navigationView;
@property (strong,nonatomic) UITableView *tableView;

@end

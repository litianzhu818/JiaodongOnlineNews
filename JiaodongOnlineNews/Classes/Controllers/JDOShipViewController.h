//
//  JDOShipViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-9-12.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JDOShipViewController : JDONavigationController<UITableViewDelegate, UITableViewDataSource>
{
    UITextField *begtime;
    UITextField *endtime;
    UIButton *Submit;
    NSArray *tableArray;
    UITableView *table;
}

- (void)backToParent;
- (void)submit;

@end

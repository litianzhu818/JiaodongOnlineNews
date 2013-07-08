//
//  JDOSelectCarTypeViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOViolationViewController.h"

@interface JDOSelectCarTypeViewController : JDONavigationController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tablelist;
    
    NSArray *cartypes;
}

@property (nonatomic,strong)JDOViolationViewController *violation;

@end

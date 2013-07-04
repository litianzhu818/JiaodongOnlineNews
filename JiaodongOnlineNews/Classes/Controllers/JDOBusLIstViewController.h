//
//  JDOBusLIstViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOBusLIstViewController : JDONavigationController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tablelist;
    
    NSMutableArray *buslines;
}

- (void)loadDataFromNetwork;

@end

//
//  JDOBusLIstViewController.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOStatusView.h"

@interface JDOBusLIstViewController : JDONavigationController <JDOStatusView, JDOStatusViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tablelist;
    NSMutableArray *buslines;
}

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;

- (void)loadDataFromNetwork;

@end

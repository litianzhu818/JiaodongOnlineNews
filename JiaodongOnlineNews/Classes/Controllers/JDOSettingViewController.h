//
//  JDOSettingViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-22.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDORightViewController.h"

typedef enum {
    JDOSettingItemPushService = 0,
    JDOSettingItem3GSwitch,
    JDOSettingItemClearCache,
    JDOSettingItemDownload,
    JDOSettingItemCheckVersion,
    JDOSettingItemFeedback,
    JDOSettingItemCount
} JDOSettingItem;

@interface JDOSettingViewController : JDONavigationController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

- (void)onPopularizeButtonClick:(UIButton *)button;
- (void)sendToServer:(NSDictionary *)params;

@end

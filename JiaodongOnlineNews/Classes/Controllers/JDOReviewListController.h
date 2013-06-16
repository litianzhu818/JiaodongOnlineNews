//
//  JDOReviewListController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOListViewController.h"

@interface JDOReviewListController : JDOListViewController<UITableViewDelegate, UITableViewDataSource>

-(id)initWithParams:(NSDictionary *)params;

@end

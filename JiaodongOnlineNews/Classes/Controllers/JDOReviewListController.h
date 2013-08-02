//
//  JDOReviewListController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOListViewController.h"
#import "JDOToolBar.h"
#import "JDOToolbarModel.h"

@interface JDOReviewListController : JDOListViewController<UITableViewDelegate, UITableViewDataSource>

-(id)initWithType:(JDOReviewType)type params:(NSDictionary *)params;
@property (nonatomic,strong) id<JDOToolbarModel> model;

@end

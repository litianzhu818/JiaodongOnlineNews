//
//  JDONewsDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOToolBar.h"
#import "JDONewsDetailController.h"

@class JDOPartyModel;

@interface JDOPartyDetailController : JDOWebViewController

@property (nonatomic,strong) JDOPartyModel *partyModel;

- (id)initWithPartyModel:(JDOPartyModel *)partyModel;
@end

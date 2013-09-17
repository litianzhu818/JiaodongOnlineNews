//
//  JDONewsDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOPartyJoinController : JDONavigationController <UITextFieldDelegate>
@property (nonatomic,strong) NSDictionary *partyJoin;
- (id)initWithPartyJoin:(NSDictionary *)partyJoin;

@end

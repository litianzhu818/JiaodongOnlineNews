//
//  JDOShareController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-13.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOToolbarModel.h"

@interface JDOShareViewController : JDONavigationController

@property (strong,nonatomic) id<JDOToolbarModel> model;

- (id) initWithModel:(id<JDOToolbarModel>) model;

@end

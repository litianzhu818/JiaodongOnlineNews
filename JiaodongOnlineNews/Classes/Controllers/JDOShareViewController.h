//
//  JDOShareController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-13.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDONewsModel.h"

@interface JDOShareViewController : UIViewController <JDONavigationView>

@property (strong,nonatomic) JDONavigationView *navigationView;
@property (strong,nonatomic) JDONewsModel *newsModel;

- (id) initWithNewsModel:(JDONewsModel *)newsModel;

@end

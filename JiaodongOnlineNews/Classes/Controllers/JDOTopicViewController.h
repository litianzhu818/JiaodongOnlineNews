//
//  JDOTopicViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-1.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOTopicViewController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate>

@property (nonatomic,assign) ViewStatusType status;
@property (strong,nonatomic) JDOStatusView *statusView;
- (void) setCurrentState:(ViewStatusType)status;

@end

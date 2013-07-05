//
//  JDOTopicViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-1.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGPageScrollView.h"
#import "HGPageImageView.h"

@interface JDOTopicViewController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate,HGPageScrollViewDelegate, HGPageScrollViewDataSource>

@property (nonatomic,assign) ViewStatusType status;
@property (strong,nonatomic) JDOStatusView *statusView;
- (void) setCurrentState:(ViewStatusType)status;

@property (strong,nonatomic) HGPageScrollView *horizontalScrollView;
@property (strong,nonatomic) NSMutableArray   *listArray;

@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *modelClass;
@property (nonatomic,strong) NSMutableDictionary *listParam;

- (void) returnFromDetail;

@end
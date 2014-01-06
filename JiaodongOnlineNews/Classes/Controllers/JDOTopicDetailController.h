//
//  JDOTopicDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOToolBar.h"
#import "JDOTopicViewController.h"
#import "JDOWebViewController.h"

@class JDOTopicModel;

@interface JDOTopicDetailController : JDOWebViewController <UITextViewDelegate,JDOShareTargetDelegate>

@property (nonatomic,strong) JDOTopicModel *topicModel;
@property (nonatomic,strong) JDOTopicViewController *pController;

- (id)initWithTopicModel:(JDOTopicModel *)topicModel pController:(JDOTopicViewController *)pController;

@end
//
//  JDOLivehoodDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-11.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationController.h"

@class JDOQuestionModel;
@class JDOToolBar;

@interface JDOQuestionDetailController : JDONavigationController<JDOStatusView,JDOStatusViewDelegate>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (strong,nonatomic) UIScrollView *mainView;
@property (nonatomic,strong) JDOToolBar *toolbar;

@property (nonatomic,strong) JDOQuestionModel *questionModel;

- (id)initWithQuestionModel:(JDOQuestionModel *)questionModel;

@end

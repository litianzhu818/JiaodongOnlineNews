//
//  JDOQuestionReviewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-15.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@class JDOQuestionModel;

@interface JDOQuestionReviewController : JDONavigationController

@property (strong,nonatomic) TPKeyboardAvoidingScrollView *mainView;

@property (nonatomic,strong) JDOQuestionModel *questionModel;

- (id)initWithQuestionModel:(JDOQuestionModel *)questionModel;

@end

//
//  JDOLivehoodQuestionList.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"

@interface JDOLivehoodQuestionList : NIPageView <JDOStatusView>

@property (strong,nonatomic) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,assign) NSDictionary *info;

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info;

- (void)loadDataFromNetwork;

@end

//
//  JDOLivehoodAskQuestion.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"
//#import "PopoverView.h"

@interface JDOLivehoodAskQuestion : NIPageView 

@property (nonatomic,assign) NSDictionary *info;
@property (assign,nonatomic) UIView *rootView;

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info rootView:(UIView *)rootView;


@end

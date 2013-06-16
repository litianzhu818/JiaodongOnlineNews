//
//  JDONewsReviewView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-16.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import <AGCommon/CMHTableView.h>
#import <ShareSDK/ISSShareViewDelegate.h>
#import "JDONewsDetailController.h"

@interface JDONewsReviewView : UIView <HPGrowingTextViewDelegate,CMHTableViewDataSource,CMHTableViewDelegate,ISSViewDelegate>

@property (strong, nonatomic) HPGrowingTextView *textView;
@property (strong, nonatomic) UILabel *remainWordNum;

- (id)initWithFrame:(CGRect)frame controller:(JDONewsDetailController *)controller;

@end

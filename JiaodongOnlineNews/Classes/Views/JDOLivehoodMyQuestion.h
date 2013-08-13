//
//  JDOLivehoodMyQuestion.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"

@interface JDOLivehoodMyQuestion : NIPageView <JDOStatusView, UITableViewDelegate, UITableViewDataSource,JDOStatusViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) JDOStatusView *statusView;
@property (nonatomic,assign) ViewStatusType status;
@property (nonatomic,assign) NSDictionary *info;
@property (nonatomic,strong) UITableView *tableView;
@property (strong,nonatomic) UIView *rootView;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) NSMutableArray *idsArray;
@property (strong,nonatomic) UIImageView *noDataView;

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info rootView:(UIView *)rootView;

- (void)loadDataFromNetwork;

@end

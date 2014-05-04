//
//  JDOVideoViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "NimbusPagingScrollView.h"

@class JDOPageControl;
@class NIPagingScrollView;

@interface JDOVideoViewController : JDONavigationController <UIScrollViewDelegate,NIPagingScrollViewDelegate,NIPagingScrollViewDataSource>

@property (nonatomic,strong) NIPagingScrollView *scrollView;
@property (nonatomic,strong) JDOPageControl *pageControl;
@property (nonatomic,strong) JDOAppDelegate *myDelegate;

@end

//
//  JDOCollectViewController.h
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-7-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//  收藏界面


#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"
#import "JDORightViewController.h"

@class JDOPageControl;
@class NIPagingScrollView;

@interface JDOCollectViewController : JDONavigationController <UIScrollViewDelegate,NIPagingScrollViewDelegate,NIPagingScrollViewDataSource>

/**
 存放内容的控件
 */
@property (nonatomic,strong) NIPagingScrollView *scrollView;
/**
 顶部标签页
 */
@property (nonatomic,strong) JDOPageControl *pageControl;

@end
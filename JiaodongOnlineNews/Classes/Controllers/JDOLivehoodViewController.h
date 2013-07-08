//
//  JDOLivehoodViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NimbusPagingScrollView.h"

@class JDOPageControl;
@class NIPagingScrollView;

@interface JDOLivehoodViewController : JDONavigationController <UIScrollViewDelegate,NIPagingScrollViewDelegate,NIPagingScrollViewDataSource>

/**
 存放内容的控件
 */
@property (nonatomic,strong) NIPagingScrollView *scrollView;
/**
 顶部标签页
 */
@property (nonatomic,strong) JDOPageControl *pageControl;

@end

//
//  JDOPageControl.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOPageControl : UIControl<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *slider;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, assign) int numberOfPages, currentPage, lastPageIndex;
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, assign,getter = isAnimating) BOOL animating;

- (id)initWithFrame:(CGRect)frame background:(NSString *)backgroundImage slider:(NSString *)sliderImage pages:(NSArray *)pages;
- (void)setCurrentPage:(int)_currentPage animated:(BOOL)animated;
- (void) setTitleFontSize:(CGFloat) size;

@end

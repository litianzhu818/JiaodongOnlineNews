//
//  JDONewsHeadCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsHeadCell.h"
#import "JDONewsModel.h"
#import "JDONewsViewController.h"
#import "JDOPageControl.h"

#define Default_Image @"news_head_placeholder.png"
#define Title_Height 25.0f
#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define PageControl_Width 40.0f

@implementation JDONewsHeadCell {
    NSArray *originModels;
    NSArray *originImages;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.frame = CGRectMake(0, 0, 320, Headline_Height);    //self.bounds=44
        
        float width = CGRectGetWidth(self.bounds);
        float height = CGRectGetHeight(self.bounds);
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width,height)];
        _scrollView.contentSize = CGSizeMake(width, height);
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.bounces = false;
        _scrollView.pagingEnabled = true;
        _scrollView.delegate = self;
        
        self.imageViews = [NSMutableArray arrayWithCapacity:1];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imageView.image = [UIImage imageNamed:Default_Image];
        [self.imageViews addObject:imageView];
        [_scrollView addSubview:imageView];
        [self.contentView addSubview:_scrollView];
        
        _titleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, height-Title_Height, width, Title_Height)];
        _titleBackground.image = [UIImage imageNamed:@"news_head_title_background.png"];
        
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(Left_Margin, height-Title_Height, width-PageControl_Width-Left_Margin-Right_Margin, Title_Height)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = UITextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(0, 1);
        [self.contentView addSubview:_titleLabel];
        
        _pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(width-PageControl_Width-Right_Margin, height-Title_Height, PageControl_Width, Title_Height)];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.coreNormalColor = [UIColor colorWithHex:@"A1A1A1"];
        _pageControl.coreSelectedColor = [UIColor colorWithHex:@"006FD7"];
        _pageControl.numberOfPages = 0;
        [self.contentView addSubview:_pageControl];
        
        self._currentPage = 0;
    }
    return self;
}

- (void)setModels:(NSArray *)models{
    _models = models;
    originModels = [models copy];
    // _titleBackground在有数据的时候才添加到contentView,是为了在显示占位图的时候不显示
    if( _titleBackground.superview == nil){
        [self.contentView insertSubview:_titleBackground belowSubview:_titleLabel];
    }
    
    for(UIImageView *imageView in self.imageViews){
        [imageView removeGestureRecognizer:[imageView.gestureRecognizers lastObject] ];
    }
    self.imageViews = [NSMutableArray arrayWithCapacity:models.count];
    // 移除之前的图像,包括最初的占位图
    [[_scrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    float width = CGRectGetWidth(self.bounds);
    float height = CGRectGetHeight(self.bounds);
    
    _scrollView.contentSize = CGSizeMake(models.count *width, height);
    for (int i=0; i<models.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*width, 0, width, height)];
        imageView.userInteractionEnabled = true;    // UIImageView默认不开启userInteraction
        [self.imageViews addObject:imageView];
        [_scrollView addSubview:imageView];
        
        JDONewsModel *newsModel = (JDONewsModel *)[models objectAtIndex:i];
        if( i==self._currentPage ){
            _titleLabel.text = newsModel.title;
        }
            
        __block UIImageView *blockImageView = imageView;
        [imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:newsModel.mpic]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
            if(!cached){    // 非缓存加载时使用渐变动画
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [blockImageView.layer addAnimation:transition forKey:nil];
            }
        } failure:^(NSError *error) {
            	
        }];
    }
    originImages = [self.imageViews copy];
    _pageControl.numberOfPages = models.count;
    _pageControl.currentPage = 0;
    
    //如果不在第一页（烟台新闻），则把第一个view放到scrollview中间
    int page = [[[JDOCenterViewController sharedNewsViewController] pageControl] currentPage];
    if (page != 0) {
        CGFloat pageWidth = _scrollView.frame.size.width;
        self._currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        JDONewsModel *newsModel = (JDONewsModel *)[_models objectAtIndex:0];
        _titleLabel.text = newsModel.title;
        [self pageMoveToRight];
        
        CGPoint p = CGPointZero;
        p.x = pageWidth;
        [_scrollView setContentOffset:p animated:NO];
    }
    
}

- (void)dealloc{
    for(UIImageView *imageView in self.imageViews){
        [imageView removeGestureRecognizer:[imageView.gestureRecognizers lastObject] ];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 修改pageControl的位置和titleLabel的内容
    CGFloat pageWidth = scrollView.frame.size.width;
    self._currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //float pageWidth = CGRectGetWidth(self.bounds);
    //self._currentPage = _scrollView.contentOffset.x / pageWidth;
    JDONewsModel *newsModel = (JDONewsModel *)[self.models objectAtIndex:self._currentPage];
    _pageControl.currentPage = [originModels indexOfObject:newsModel];
    _titleLabel.text = newsModel.title;
    
    //NSLog(@"self._currentPage   %d", self._currentPage);
    //NSLog(@"_pageControl.currentPage   %d", _pageControl.currentPage);
    int page = [[[JDOCenterViewController sharedNewsViewController] pageControl] currentPage];
    if(self._currentPage == 1) {
        return;
    } else if (self._currentPage == 0) {
        if (page == 0 && _pageControl.currentPage==0) {
            return;
        } else {
            //在最后一页第一个头条向右滑动的时候，将整个序列恢复成原始序列
            if (page == [JDOCenterViewController sharedNewsViewController].pageControl.numberOfPages-1 && _pageControl.currentPage==2 && self._currentPage == 0) {
                [self.imageViews removeAllObjects];
                [self.models removeAllObjects];
                [self.imageViews addObjectsFromArray:originImages];
                [self.models addObjectsFromArray:originModels];
                [self setPageFrame];
                CGPoint p = CGPointZero;
                p.x = pageWidth*2;
                [scrollView setContentOffset:p animated:NO];
            } else {
                [self pageMoveToRight];
                CGPoint p = CGPointZero;
                p.x = pageWidth;
                [scrollView setContentOffset:p animated:NO];
            }
        }
    } else {
        if (page == [JDOCenterViewController sharedNewsViewController].pageControl.numberOfPages-1 && _pageControl.currentPage == _pageControl.numberOfPages-1) {
            return;
        } else {
            //在第一页第三个头条向左滑动的时候，将整个序列恢复成原始序列
            if (page == 0 && _pageControl.currentPage==0 && self._currentPage == 2) {
                [self.imageViews removeAllObjects];
                [self.models removeAllObjects];
                [self.imageViews addObjectsFromArray:originImages];
                [self.models addObjectsFromArray:originModels];
                [self setPageFrame];
                CGPoint p = CGPointZero;
                p.x = 0;
                [scrollView setContentOffset:p animated:NO];
            } else {
                [self pageMoveToLeft];
                CGPoint p = CGPointZero;
                p.x = pageWidth;
                [scrollView setContentOffset:p animated:NO];
            }
        }
    }
}

-(void)setPageFrame {
    ((UIImageView *)[self.imageViews objectAtIndex:0]).frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
    ((UIImageView *)[self.imageViews objectAtIndex:1]).frame = CGRectMake(_scrollView.frame.origin.x + _scrollView.frame.size.width, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
    ((UIImageView *)[self.imageViews objectAtIndex:2]).frame = CGRectMake(_scrollView.frame.origin.x + _scrollView.frame.size.width * 2, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
}

- (void)pageMoveToRight {
    UIView *tmp = (UIImageView *)[self.imageViews objectAtIndex:1];
    [self.imageViews setObject:((UIImageView *)[self.imageViews objectAtIndex:0]) atIndexedSubscript:1];
    [self.imageViews setObject:((UIImageView *)[self.imageViews objectAtIndex:2]) atIndexedSubscript:0];
    [self.imageViews setObject:tmp atIndexedSubscript:2];

    NSObject *temp = [self.models objectAtIndex:1];
    [self.models setObject:[self.models objectAtIndex:0] atIndexedSubscript:1];
    [self.models setObject:[self.models objectAtIndex:2] atIndexedSubscript:0];
    [self.models setObject:temp atIndexedSubscript:2];
    
    [self setPageFrame];
}

- (void)pageMoveToLeft {
    UIView *tmp = (UIImageView *)[self.imageViews objectAtIndex:1];
    [self.imageViews setObject:((UIImageView *)[self.imageViews objectAtIndex:2]) atIndexedSubscript:1];
    [self.imageViews setObject:((UIImageView *)[self.imageViews objectAtIndex:0]) atIndexedSubscript:2];
    [self.imageViews setObject:tmp atIndexedSubscript:0];
    
    NSObject *temp = [self.models objectAtIndex:1];
    [self.models setObject:[self.models objectAtIndex:2] atIndexedSubscript:1];
    [self.models setObject:[self.models objectAtIndex:0] atIndexedSubscript:2];
    [self.models setObject:temp atIndexedSubscript:0];
    
    [self setPageFrame];
}
@end

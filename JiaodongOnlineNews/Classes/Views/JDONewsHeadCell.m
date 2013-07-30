//
//  JDONewsHeadCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsHeadCell.h"
#import "JDONewsModel.h"

#define Default_Image @"news_head_placeholder.png"
#define Title_Height 25.0f
#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define PageControl_Width 40.0f

@implementation JDONewsHeadCell{
    int _currentPage;
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
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(width-PageControl_Width-Right_Margin, height-Title_Height, PageControl_Width, Title_Height)];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.numberOfPages = 0;
        [self.contentView addSubview:_pageControl];
        
        _currentPage = 0;
    }
    return self;
}

- (void)setModels:(NSArray *)models{
    _models = models;
    
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
        if( i==_currentPage ){
            _titleLabel.text = newsModel.title;
        }
            
        __block UIImageView *blockImageView = imageView;
        [imageView setImageWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:newsModel.mpic]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
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
#warning _pageControl图标样式需要改为蓝色
    _pageControl.numberOfPages = models.count;
    _pageControl.currentPage = _currentPage;
}

- (void)dealloc{
    for(UIImageView *imageView in self.imageViews){
        [imageView removeGestureRecognizer:[imageView.gestureRecognizers lastObject] ];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 修改pageControl的位置和titleLabel的内容
    float width = CGRectGetWidth(self.bounds);
    _currentPage = _scrollView.contentOffset.x / width;
    _pageControl.currentPage = _currentPage;
    JDONewsModel *newsModel = (JDONewsModel *)[self.models objectAtIndex:_currentPage];
    _titleLabel.text = newsModel.title;
}


@end

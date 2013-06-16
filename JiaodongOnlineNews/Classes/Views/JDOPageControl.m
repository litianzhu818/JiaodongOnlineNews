//
//  JDONavigationView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPageControl.h"
#import "JDONewsCategoryInfo.h"

#define MASK_VISIBLE_ALPHA 0.5
#define UPPER_TOUCH_LIMIT -10
#define LOWER_TOUCH_LIMIT 10
#define slider_top_margin 5
#define slider_left_margin 5
#define title_label_tag 100
#define title_normal_color [UIColor blackColor]
#define title_highlight_color [UIColor whiteColor]

@implementation JDOPageControl

- (id)initWithFrame:(CGRect)frame background:(NSString *)backgroundImage slider:(NSString *)sliderImage pages:(NSArray *)pages{
    if (self = [super initWithFrame:frame]) {
        // 背景色
		_backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        [_backgroundView setImage:[UIImage imageNamed:backgroundImage]];
        [self addSubview:_backgroundView];
        [self sendSubviewToBack:_backgroundView];
		// 滑动背景
		_slider = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_slider setImage:[[UIImage imageNamed:sliderImage] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        [self insertSubview:_slider aboveSubview:_backgroundView];
        
        [self setPages:pages];
    }
    return self;
}

-(void) setPages:(NSArray *)pages{
    _animating = false;
    _currentPage = -1;
    _pages = pages;
    _numberOfPages = pages.count;
    int width = self.frame.size.width/pages.count;
    for (int i=0; i<pages.count; i++) {
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(i*width, 0, width,self.frame.size.height)];
        [titleBtn setTitle:[(JDONewsCategoryInfo *)[pages objectAtIndex:i] title] forState:UIControlStateNormal];
        [titleBtn setTitleColor:title_normal_color forState:UIControlStateNormal];
        titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        titleBtn.tag = title_label_tag+i;
        titleBtn.backgroundColor = [UIColor clearColor];
        [titleBtn addTarget:self action:@selector(onTitleClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:titleBtn];
    }
}

- (void)onTitleClicked:(UIButton *)titleBtn{
    int toPageIndex = titleBtn.tag - title_label_tag;
    if(_currentPage == toPageIndex) return;
    if(_animating == false) {
        _animating = true;
        [self setCurrentPage:toPageIndex animated:true];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}

- (void)setCurrentPage:(int)toPage{
    [self setCurrentPage:toPage animated:NO];
}

- (void)setCurrentPage:(int)toPage animated:(BOOL)animated{
    // 在scrollView中滑动时会持续触发该函数，增加currentPage的判断可优化执行
    if(_currentPage == toPage){
        _animating = false;
        return;
    }
    [self setTitleOfIndex:_currentPage toColor:title_normal_color];
    _currentPage = toPage;
	if (animated){
		[UIView beginAnimations:@"moveSlider" context:nil];
        [UIView setAnimationDelegate:self];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	}
	
	int width = self.frame.size.width/self.numberOfPages;
	int x = width*_currentPage;
    // 也可以只修改center,设置为对应labelButton的center
	[self.slider setFrame:CGRectMake(x+slider_left_margin,slider_top_margin,width-slider_left_margin*2,self.frame.size.height-slider_top_margin*2)];
	if (animated){
        [UIView commitAnimations];
    }else{
        [self setTitleOfIndex:toPage toColor:title_highlight_color];
    }
}

- (void)setTitleOfIndex:(int)index toColor:(UIColor *)color{
    if(index<0) return;
    UIButton *titleButton = (UIButton *)[self viewWithTag:title_label_tag+index];
    [titleButton setTitleColor:color forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	float diameter = 5;
	
	CGFloat blackColor[4];
	blackColor[0]=0.0;
	blackColor[1]=0.0;
	blackColor[2]=0.0;
	blackColor[3]=1.0;
	float width = self.frame.size.width/self.numberOfPages;
	
	int i;
	for (i=0; i<self.numberOfPages; i++)
	{
		int x = i*width + (width-diameter)/2;
		CGContextSetFillColor(myContext, blackColor);
		CGContextFillEllipseInRect(myContext, CGRectMake(x,(self.frame.size.height-diameter)/2,diameter,diameter));
	}
}


-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if([animationID isEqualToString:@"moveSlider"] && [finished boolValue]){
        [self setTitleOfIndex:_currentPage toColor:title_highlight_color];
        _animating = false;
    }
    
}

@end

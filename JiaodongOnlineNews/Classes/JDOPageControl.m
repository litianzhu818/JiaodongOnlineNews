//
//  JDONavigationView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPageControl.h"

#define MASK_VISIBLE_ALPHA 0.5
#define UPPER_TOUCH_LIMIT -10
#define LOWER_TOUCH_LIMIT 10
#define slider_top_margin 5
#define slider_left_margin 5
#define title_label_tag 100

@implementation JDOPageControl

int touchDownIndex;

- (id)initWithFrame:(CGRect)frame background:(NSString *)backgroundImage slider:(NSString *)sliderImage {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		[self setBackgroundColor:[UIColor clearColor]];
		_backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
		[_backgroundView setBackgroundColor:[UIColor clearColor]];
		[self addSubview:_backgroundView];
		
		_slider = [[UIImageView alloc] initWithFrame:CGRectZero];
		[_slider setBackgroundColor:[UIColor clearColor]];
		[_slider setAlpha:0.8];
		[self addSubview:_slider];
		
		[_backgroundView setImage:[UIImage imageNamed:backgroundImage]];
		[_slider setImage:[[UIImage imageNamed:sliderImage] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        _animating = false;
        _currentPage = -1;
    }
    return self;
}

-(void) setPages:(NSArray *)pages{
    _pages = pages;
    int width = self.frame.size.width/pages.count;
    for (int i=0; i<pages.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*width, 0, width,self.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [[pages objectAtIndex:i] objectForKey:@"title"];
        label.tag = title_label_tag+i;
        label.backgroundColor = [UIColor clearColor];
        [_backgroundView addSubview:label];
    }
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-slider_left_margin*2,self.frame.size.height-slider_top_margin*2)];
    sliderLabel.backgroundColor = [UIColor clearColor];
    sliderLabel.tag = title_label_tag;
    sliderLabel.textAlignment = NSTextAlignmentCenter;
    sliderLabel.textColor = [UIColor whiteColor];
    [_slider addSubview:sliderLabel];
    
    [self setNumberOfPages:pages.count];
}

- (void)setCurrentPage:(int)currentPage{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(int)currentPage animated:(BOOL)animated{
    if(_currentPage == currentPage){
        _animating = false;
        return;
    }
	if (animated){
        [self hideSliderLabel];
        _currentPage = currentPage;
		[UIView beginAnimations:@"moveSlider" context:nil];
        [UIView setAnimationDelegate:self];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	}else{
        _currentPage = currentPage;
        [self showSliderLabel];
    }
    
	
	int width = self.frame.size.width/self.numberOfPages;
	int x = width*currentPage;
	[self.slider setFrame:CGRectMake(x+slider_left_margin,slider_top_margin,width-slider_left_margin*2,self.frame.size.height-slider_top_margin*2)];
	if (animated){
        [UIView commitAnimations];
    }
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

#pragma mark touch delegate


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    touchDownIndex = [self labelIndexOfPoint:[[touches anyObject] locationInView:self]];
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
	int touchUpIndex = [self labelIndexOfPoint:[[touches anyObject] locationInView:self]];
    if(touchDownIndex == touchUpIndex && _animating == false) {
        _animating = true;
        [self setCurrentPage:touchDownIndex animated:true];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
	[super touchesEnded:touches withEvent:event];
}

-(int)labelIndexOfPoint:(CGPoint) point{
    for (int i=0; i<self.numberOfPages; i++){
        float max_x = (i+1)*(self.frame.size.width/self.numberOfPages);
        if (point.x<=max_x){
            if( point.y>UPPER_TOUCH_LIMIT && point.y<self.frame.size.height+LOWER_TOUCH_LIMIT){
                return i;
            }else{
                return -1;
            }
        }
    }
    return -1;
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if([animationID isEqualToString:@"moveSlider"] && [finished boolValue]){
        [self showSliderLabel];
        _animating = false;
    }
    
}

-(void)showSliderLabel{
    [_backgroundView viewWithTag:title_label_tag+_currentPage].hidden = true;
    UILabel *sliderLabel = (UILabel *)[_slider viewWithTag:title_label_tag];
    [sliderLabel setHidden:false];
    [sliderLabel setText:[[_pages objectAtIndex:_currentPage] objectForKey:@"title"]];
}

-(void)hideSliderLabel{
    [_backgroundView viewWithTag:title_label_tag+_currentPage].hidden = false;
    UILabel *sliderLabel = (UILabel *)[_slider viewWithTag:title_label_tag];
    [sliderLabel setHidden:true];
}

@end

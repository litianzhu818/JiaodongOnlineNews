/**
 * Copyright (c) 2010 Muh Hon Cheng
 * Created by honcheng on 12/11/10.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2010	Muh Hon Cheng
 * @version
 * 
 */

#import "SliderPageControl.h"

#define MASK_VISIBLE_ALPHA 0.5
#define UPPER_TOUCH_LIMIT -50
#define slider_top_margin 5
#define slider_left_margin 5
#define title_label_tag 100

@interface SliderPageControl()
- (void)showMaskView:(BOOL)show;
- (void)displayHintForPage:(int)page;
- (void)removeMaskView;
@end

@implementation SliderPageControl

int lastPageIndex = -1;

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
    }
    return self;
}

-(void) setPages:(NSArray *)pages{
    int width = self.frame.size.width/pages.count;
    for (int i=0; i<pages.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*width, 0, width,self.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [[pages objectAtIndex:i] objectForKey:@"title"];
        label.tag = title_label_tag+i;
        label.backgroundColor = [UIColor clearColor];
        [_backgroundView addSubview:label];
    }
    
    [self setNumberOfPages:pages.count];
    [self setNeedsDisplay];
    [self setCurrentPage:0];
    
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width-slider_left_margin*2,self.frame.size.height-slider_top_margin*2)];
    [self.slider addSubview:sliderLabel];
}

- (void)setCurrentPage:(int)currentPage{
    [self setCurrentPage:currentPage animated:NO];
}

- (void)setCurrentPage:(int)currentPage animated:(BOOL)animated{
	_currentPage = currentPage;
	
	if (animated){
        [[self.slider viewWithTag:title_label_tag] setHidden:true];
		[UIView beginAnimations:@"moveSlider" context:nil];
        [UIView setAnimationDelegate:self];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
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

#pragma mark mask view

- (void)showMaskView:(BOOL)show
{
	if (show)
	{
		if (self.maskView==nil)
		{
			self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[self window].frame.size.width,[self window].frame.size.height)];
			[self.maskView setBackgroundColor:[UIColor blackColor]];
			[[self superview] insertSubview:self.maskView belowSubview:self];
			
			self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,20,self.maskView.frame.size.width-40,self.maskView.frame.size.height-40)];
			[self.hintLabel setBackgroundColor:[UIColor clearColor]];
			[self.hintLabel setFont:[UIFont boldSystemFontOfSize:30]];
			[self.hintLabel setNumberOfLines:10];
			[self.hintLabel setTextAlignment:UITextAlignmentCenter];
			[self.hintLabel setTextColor:[UIColor whiteColor]];
			[self.hintLabel setShadowColor:[UIColor blackColor]];
			[self.hintLabel setShadowOffset:CGSizeMake(0,-1)];
			[self.maskView addSubview:self.hintLabel];
			
			[self.maskView setAlpha:0.0];
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[self.maskView setAlpha:MASK_VISIBLE_ALPHA];
			[UIView commitAnimations];
		}
	}
	else
	{
		if (self.maskView!=nil)
		{
			[self.maskView setAlpha:MASK_VISIBLE_ALPHA];
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(removeMaskView)];
			[self.maskView setAlpha:0.0];
			[UIView commitAnimations];
		}
		
	}
}

- (void)displayHintForPage:(int)page
{
	if (self.hintLabel!=nil)
	{
		if (self.showsHint)
		{
			if ([self.delegate respondsToSelector:@selector(sliderPageController:hintTitleForPage:)])
			{
				NSString *hintText = [self.delegate sliderPageController:self hintTitleForPage:page];
				[self.hintLabel setText:hintText];
			}
			else
			{
				[self.hintLabel setText:[NSString stringWithFormat:@"%i", page]];
			}
		}
		else
		{
			[self.hintLabel setText:@""];
		}
	}
	
}

- (void)removeMaskView
{
	[self.maskView removeFromSuperview];
	self.maskView = nil;
	self.hintLabel = nil;
}

- (void)sendTitleToBack{
    if(lastPageIndex != -1){
        UILabel *title = (UILabel *)[_slider viewWithTag:title_label_tag+lastPageIndex ];
        [title setTextColor:[UIColor blackColor]];
        [title removeFromSuperview];
        int width = self.frame.size.width/_numberOfPages;
        CGRect frame = title.frame;
        frame.origin.x = lastPageIndex*width;
        frame.size.width += slider_left_margin*2;
        frame.size.height += slider_top_margin*2;
        title.frame = frame;
        [_backgroundView insertSubview:title atIndex:0];
    }
}

#pragma mark touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self sendTitleToBack];
    
	self.beganPoint = CGPointMake(self.slider.frame.origin.x, self.slider.frame.origin.y);
	CGPoint movedPoint = [[touches anyObject] locationInView:self];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	CGRect sliderFrame = [self.slider frame];
	float x = movedPoint.x - sliderFrame.size.width/2;
	if (x<0) x=0;
	else if (x>self.frame.size.width-sliderFrame.size.width) x = self.frame.size.width-sliderFrame.size.width;
	
	sliderFrame.origin.x = x;
	[self.slider setFrame:sliderFrame];
	
	[UIView commitAnimations];
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.hasDragged) [self showMaskView:YES];
	
	self.hasDragged = YES;
	CGPoint movedPoint = [[touches anyObject] locationInView:self];
	
	CGRect sliderFrame = [self.slider frame];
	float x = movedPoint.x - sliderFrame.size.width/2;
	if (x<0) x=0;
	else if (x>self.frame.size.width-sliderFrame.size.width) x = self.frame.size.width-sliderFrame.size.width;
	
	sliderFrame.origin.x = x;
	[self.slider setFrame:sliderFrame];
	
	[super touchesMoved:touches withEvent:event];

	int hintPage = 0;
	float center_x = [self.slider frame].origin.x + [self.slider frame].size.width/2;
	int i;
	for (i=0; i<self.numberOfPages; i++)
	{
		float max_x = (i+1)*(self.frame.size.width/self.numberOfPages);
		if (center_x<=max_x)
		{
			hintPage = i;
			break;
		}
	}
	[self displayHintForPage:hintPage];
	
	if (movedPoint.y<UPPER_TOUCH_LIMIT)
	{
		float difference = UPPER_TOUCH_LIMIT - movedPoint.y;
		float full = 300;
		float ratio = 1 - difference/full;
		if (ratio<0) ratio = 0;
		[self.maskView setAlpha:MASK_VISIBLE_ALPHA*ratio];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.hasDragged) [self showMaskView:NO];
	self.hasDragged = NO;
	
	CGPoint endPoint = [[touches anyObject] locationInView:self];
	
	if (endPoint.y<UPPER_TOUCH_LIMIT || endPoint.y>self.frame.size.height)
	{
		// ended outside, considered a cancel, should snap to original location

		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		CGRect sliderFrame = [self.slider frame];
		sliderFrame.origin.x = self.beganPoint.x;
		[self.slider setFrame:sliderFrame];
		[UIView commitAnimations];
	}
	else
	{
		// touch ended inside, should snap to new location
		float center_x = [self.slider frame].origin.x + [self.slider frame].size.width/2;
		int i;
		for (i=0; i<self.numberOfPages; i++)
		{
			float max_x = (i+1)*(self.frame.size.width/self.numberOfPages);
			if (center_x<=max_x)
			{
                [self sendTitleToBack];
                
				[UIView beginAnimations:@"moveSlider" context:nil];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationDelegate:self];
				CGRect sliderFrame = [self.slider frame];
				sliderFrame.origin.x = (i)*(self.frame.size.width/self.numberOfPages);
				[self.slider setFrame:sliderFrame];
				[UIView commitAnimations];
                
                self.currentPage = i;
				[self sendActionsForControlEvents:UIControlEventValueChanged];
				
				break;
			}
		}
	}
	[super touchesEnded:touches withEvent:event];
}

-(void)animationDidStop:(NSString *)animationID finished:(BOOL)flag context:(void *)context{
    if([animationID isEqualToString:@"moveSlider"]){
        lastPageIndex = self.currentPage;
        UILabel *title = (UILabel *)[_backgroundView viewWithTag:title_label_tag+self.currentPage ];
        [title setTextColor:[UIColor whiteColor]];
        [title removeFromSuperview];
        CGRect frame = title.frame;
        frame.origin.x = 0;
        frame.size.width -=slider_left_margin*2;
        frame.size.height -= slider_top_margin*2;
        title.frame = frame;
        [_slider insertSubview:title atIndex:0];
    }
    
}

@end

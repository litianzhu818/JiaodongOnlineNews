//
//  JDOChannelItem.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-1-17.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOChannelItem.h"

@implementation JDOChannelItem{
    UILongPressGestureRecognizer *longPress;
    float itemWidth ,itemHeight;
    UIImageView *substitute;
}

- (id)initWithModel:(NSDictionary *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        self.lastCenter = self.center;
        itemWidth = 72;
        itemHeight = 31;
        substitute = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"channel_sort_border"]];
        
        NSString *title = [model objectForKey:@"channelname"];
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHex:@"646464"] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:16]];
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
    }
    return self;
}

- (void) setSection:(ChannelItemSection)section{
    _section = section;
    if (section == ChannelItemSectionSelected){
        [self setBackgroundImage:[UIImage imageNamed:@"channel_selected"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"channel_item_highlight"] forState:UIControlStateHighlighted];
        [self addGestureRecognizer:longPress];
    }else if(section == ChannelItemSectionUnselected){
        [self setBackgroundImage:[UIImage imageNamed:@"channel_unselected"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"channel_item_highlight"] forState:UIControlStateHighlighted];
        [self removeGestureRecognizer:longPress];
    }
}

- (void) refreshFrameWithPos:(int)pos{
    self.pos = pos;
    float yOffset = 0;
    if (self.section == ChannelItemSectionSelected){
        yOffset= 34.5;
    }else if(self.section == ChannelItemSectionUnselected){
        yOffset= section2startY+34.5;
    }
    self.frame=CGRectMake(10+pos%4*(4/*左右间距*/+itemWidth), 10+yOffset+pos/4*(10/*上下间距*/+itemHeight), itemWidth, itemHeight);
}

- (void) setSubstituteWithPos:(int)pos{ // 虚线框的位置
    self.pos = pos;
    float yOffset = 34.5;
    substitute.frame = CGRectMake(10+pos%4*(4/*左右间距*/+itemWidth), 10+yOffset+pos/4*(10/*上下间距*/+itemHeight), itemWidth, itemHeight);
    [self.superview insertSubview:substitute belowSubview:self];
}

- (void)drag:(UILongPressGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.superview];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self setAlpha:0.7];
            lastPoint = point;
//            [self.layer setShadowColor:[UIColor grayColor].CGColor];
//            [self.layer setShadowOpacity:1.0f];
//            [self.layer setShadowRadius:5.0f];
//            [self.layer setShadowOffset:CGSizeMake(1, 1)];
            [self startShake];
            [self setSubstituteWithPos:self.pos];
            break;
        case UIGestureRecognizerStateChanged:
        {
            float offX = point.x - lastPoint.x;
            float offY = point.y - lastPoint.y;
            [self setCenter:CGPointMake(self.center.x + offX, self.center.y + offY)];
            // 不能移动出section区域
            CGRect section = CGRectMake(0, 34.5, 320, section2startY-34.5);
            if (!CGRectContainsRect(section,self.frame)) {
                // 重置回出界前的位置
                [self setCenter:CGPointMake(self.center.x - offX, self.center.y - offY)];
            }
            [self.delegate checkOthersWithButton:self];
            lastPoint = point;
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [self stopShake];
            [self setAlpha:1];
            [UIView animateWithDuration:0.4 animations:^{
                [self refreshFrameWithPos:self.pos];
            } completion:^(BOOL finished) {
                [self.layer setShadowOpacity:0];
                [substitute removeFromSuperview];
            }];
            break;
        }
        case UIGestureRecognizerStateCancelled:
            [self stopShake];
            [self setAlpha:1];
            break;
        case UIGestureRecognizerStateFailed:
            [self stopShake];
            [self setAlpha:1];
            break;
        default:
            break;
    }
}


- (void)startShake
{
    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    shakeAnimation.duration = 0.1;
    shakeAnimation.autoreverses = YES;
    shakeAnimation.repeatCount = MAXFLOAT;
    shakeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, -0.1, 0, 0, 1)];
    shakeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, 0.1, 0, 0, 1)];
    
    [self.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
}

- (void)stopShake
{
    [self.layer removeAnimationForKey:@"shakeAnimation"];
}

@end
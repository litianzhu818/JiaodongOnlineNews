//
//  UIView+Transition.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-6.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "UIView+Transition.h"
#import <objc/runtime.h>

#define Transition_Time 0.5f
#define Min_Scale 0.95f
#define Max_Alpah 0.4f

@implementation UIView (Transition)

static const char* shadowViewKey = "shadowViewKey";
static const char* blackMaskKey = "blackMaskKey";

- (void) pushView:(UIView *) moveInView complete:(void (^)())complete{
    
    moveInView.frame = CGRectMake(320, 0, 320, 460);
    [moveInView addSubview:self.shadowView];
    self.blackMask.alpha = 0;
    [self.superview insertSubview:self.blackMask aboveSubview:self];
    [self.superview insertSubview:moveInView aboveSubview:self.blackMask];
    
    [UIView animateWithDuration:Transition_Time animations:^{
        moveInView.frame = CGRectMake(0, 0, 320, 460);
        self.transform = CGAffineTransformMakeScale(Min_Scale, Min_Scale);
        self.blackMask.alpha = Max_Alpah;
    } completion:^(BOOL finished) {
        [self.shadowView removeFromSuperview];
        [self.blackMask removeFromSuperview];
        [moveInView removeFromSuperview];
        self.transform = CGAffineTransformIdentity;
        complete();
    }];
}

- (void) popView:(UIView *) presentView complete:(void (^)()) complete{
    
    presentView.frame = CGRectMake(0, 0, 320, 460);
    presentView.transform = CGAffineTransformMakeScale(Min_Scale, Min_Scale);
    [self addSubview:self.shadowView];
    self.blackMask.alpha = Max_Alpah;
    [self.superview insertSubview:self.blackMask belowSubview:self];
    [self.superview insertSubview:presentView belowSubview:self.blackMask];
    
    [UIView animateWithDuration:Transition_Time animations:^{
        self.frame = CGRectMake(320, 0, 320, 460);
        presentView.transform = CGAffineTransformIdentity;
        self.blackMask.alpha = 0;
    } completion:^(BOOL finished) {
        [self.shadowView removeFromSuperview];
        [self.blackMask removeFromSuperview];
        [presentView removeFromSuperview];
        self.frame = CGRectMake(0, 0, 320, 460);
        complete();
    }];

}

- (UIView *) blackMask{
    UIView  *_blackMask = objc_getAssociatedObject(self, blackMaskKey);
    if( _blackMask == nil){
        _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , 460)];
        _blackMask.backgroundColor = [UIColor blackColor];
        objc_setAssociatedObject(self, blackMaskKey, _blackMask, OBJC_ASSOCIATION_RETAIN);
    }
    return _blackMask;
}

- (UIImageView *) shadowView{
    UIImageView  *_shadowView = objc_getAssociatedObject(self, shadowViewKey);
    if( _shadowView == nil){
        _shadowView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]];
        _shadowView.frame = CGRectMake(-10, 0, 10, 460);
        objc_setAssociatedObject(self, shadowViewKey, _shadowView, OBJC_ASSOCIATION_RETAIN);
    }
    return _shadowView;
}


@end

//
//  JDONavigationView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationView.h"

@implementation JDONavigationView

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.frame];
    background.image = [UIImage imageNamed:@"top_navigation_background"];
    [self addSubview:background];
    return self;
}

- (void) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
    if(self.leftBtn ){
        [self.leftBtn removeFromSuperview];
    }
    self.leftBtn = [self getButtonWithFrame:CGRectMake(0, 0, 44, 44) image:image highlightImage:highlightImage];
    [self addSubview:self.leftBtn];
    
    // 有按钮有才增加分割线
    UIImageView *separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_navigation_separator"]];
    separatorLine.frame = CGRectMake(44, 1, 1, 42);
    [self addSubview:separatorLine];
    
}
- (void) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
    if(self.rightBtn ){
        [self.rightBtn removeFromSuperview];
    }
    self.rightBtn = [self getButtonWithFrame:CGRectMake(320-44, 0, 44, 44) image:image highlightImage:highlightImage];
    [self addSubview:self.rightBtn];
    
    // 有按钮有才增加分割线
    UIImageView *separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_navigation_separator"]];
    separatorLine.frame = CGRectMake(320-44, 1, 1, 42);
    [self addSubview:separatorLine];
}

- (UIButton *) getButtonWithFrame:(CGRect)frame image:(NSString *)image highlightImage:(NSString *)highlightImage{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightImage] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageNamed:@"navigation_button_clicked"] forState:UIControlStateHighlighted];
    return btn;
}

- (void) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector{
    [self addLeftButtonImage:image highlightImage:highlightImage];
    [self.leftBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector{
    [self addRightButtonImage:image highlightImage:highlightImage];
    [self.rightBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}
#warning 标题可以考虑用图片艺术字
- (void) setTitle:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, 320-44*2, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.text = title;
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0, -1);
    [self addSubview:titleLabel];
}

- (void) addBackButtonWithTarget:(id)target action:(SEL)selector {
    [self addLeftButtonImage:@"top_navigation_back" highlightImage:@"top_navigation_back" target:target action:selector];
}

//- (UIButton *) addCustomButtonWithTarget:(id)target action:(SEL)selector {
//    return [self addRightButtonImage:@"top_navigation_review" highlightImage:@"top_navigation_review" target:target action:selector];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

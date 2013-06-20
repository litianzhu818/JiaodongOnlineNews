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
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"top_navigation_background"] ];
    return self;
}

- (UIButton *) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
#warning 图片按钮宽度应该改回44，因为背景有渐变，更好的办法是按钮背景色透明，背景加到NavigationView上
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:highlightImage] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    return btn;
}
- (UIButton *) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
    #warning 图片按钮宽度应该改回44
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(320-50, 0, 50, 44)];
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:highlightImage] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    return btn;
}

- (UIButton *) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector{
    UIButton *btn = [self addLeftButtonImage:image highlightImage:highlightImage];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIButton *) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector{
    UIButton *btn = [self addRightButtonImage:image highlightImage:highlightImage];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void) setTitle:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, 320-44*2, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = title;
    [self addSubview:titleLabel];
}

- (UIButton *) addBackButtonWithTarget:(id)target action:(SEL)selector {
    return [self addLeftButtonImage:@"top_navigation_back" highlightImage:@"top_navigation_back_highlighted" target:target action:selector];
}

- (UIButton *) addCustomButtonWithTarget:(id)target action:(SEL)selector {
    return [self addRightButtonImage:@"right_menu" highlightImage:@"right_menu" target:target action:selector];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

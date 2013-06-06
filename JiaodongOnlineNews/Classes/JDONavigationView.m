//
//  JDONavigationView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationView.h"

@implementation JDONavigationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:1.0];
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, 320, 44)];
}

- (UIButton *) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:highlightImage] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    return btn;
}
- (UIButton *) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(320-44, 0, 44, 44)];
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

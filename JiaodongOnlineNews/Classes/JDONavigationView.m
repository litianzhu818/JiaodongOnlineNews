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

- (UIButton *) addBackButton{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setBackgroundImage:[UIImage imageNamed:@"top_navigation_back"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"top_navigation_back_highlighted"] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    return btn;
}

- (void) setTitle:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 60, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [self addSubview:titleLabel];
}

- (UIButton *) addCustomButton{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(320-44, 0, 44, 44)];
    [btn setBackgroundImage:[UIImage imageNamed:@"right_menu"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"right_menu"] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    return btn;
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

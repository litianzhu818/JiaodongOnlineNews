//
//  JDONavigationView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONavigationView.h"
#import "NimbusBadge.h"

@implementation JDONavigationView

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 320, (Is_iOS7 ? 128.0f : 93.0f) /2)];
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.frame];
    background.image = [UIImage imageNamed:Is_iOS7 ? @"top_navigation_background~iOS7" : @"top_navigation_background"];
    [self addSubview:background];
    return self;
}

- (void) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
    if(self.leftBtn ){
        [self.leftBtn removeFromSuperview];
    }
    self.leftBtn = [self getButtonWithFrame:CGRectMake(0, Is_iOS7?20:0, 44, 44) image:image highlightImage:highlightImage];
    [self addSubview:self.leftBtn];
    
    // 有按钮有才增加分割线,为了简便目前通过图片名判断,最好再加一个标志字段
    if(![image isEqualToString:@"top_navigation_back_black"]){
        UIImageView *separatorLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_navigation_separator"]];
        separatorLine.frame = CGRectMake(44, Is_iOS7?21:1, 1, 42);
        [self addSubview:separatorLine];
    }
}
- (void) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage{
    if(self.rightBtn ){
        [self.rightBtn removeFromSuperview];
    }
    self.rightBtn = [self getButtonWithFrame:CGRectMake(320-44, Is_iOS7?20:0, 44, 44) image:image highlightImage:highlightImage];
    [self addSubview:self.rightBtn];
    
    // 有按钮有才增加分割线
    separatorLineRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_navigation_separator"]];
    separatorLineRight.frame = CGRectMake(320-44, Is_iOS7?21:1, 1, 42);
    [self addSubview:separatorLineRight];
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

-(void) setRightBtnCount:(NSString *)count{
    NIBadgeView *badgeView = [[NIBadgeView alloc] initWithFrame:CGRectMake(19, 2, 25, 25)];
    badgeView.userInteractionEnabled = false;
    if([count intValue] > 0){
        badgeView.font = [UIFont boldSystemFontOfSize:12];
        badgeView.backgroundColor = [UIColor clearColor];
        [self.rightBtn addSubview:badgeView];
        if([count intValue] < 100){
            badgeView.text = count;
        }else{
            badgeView.text = @"99";
        }
    }
}

- (void) setTitle:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, Is_iOS7?20:0, 320-44*2, 44)];
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


- (void)hideRightButton{
    [self.rightBtn setHidden:YES];
    [separatorLineRight setHidden:YES];
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

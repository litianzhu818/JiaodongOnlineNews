//
//  JDONavigationView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDONavigationView : UIView

@property (nonatomic,strong) UIButton *leftBtn;
@property (nonatomic,strong) UIButton *rightBtn;

- (void) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage;
- (void) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage;

- (void) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector;
- (void) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector;

- (void) setTitle:(NSString *)title;

- (void) addBackButtonWithTarget:(id)target action:(SEL)selector;
//- (UIButton *) addCustomButtonWithTarget:(id)target action:(SEL)selector;

@end

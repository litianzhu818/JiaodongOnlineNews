//
//  JDONavigationView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDONavigationView : UIView

- (UIButton *) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage;
- (UIButton *) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage;

- (UIButton *) addLeftButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector;
- (UIButton *) addRightButtonImage:(NSString *)image highlightImage:(NSString *)highlightImage target:(id)target action:(SEL)selector;

- (void) setTitle:(NSString *)title;

- (UIButton *) addBackButtonWithTarget:(id)target action:(SEL)selector;
//- (UIButton *) addCustomButtonWithTarget:(id)target action:(SEL)selector;

@end

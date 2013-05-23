//
//  JDONavigationView.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDONavigationView : UIView

- (UIButton *) addBackButton;
- (void) setTitle:(NSString *)title;
- (UIButton *) addCustomButton;

@end

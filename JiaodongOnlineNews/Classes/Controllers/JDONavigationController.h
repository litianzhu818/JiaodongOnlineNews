//
//  JDONavigationController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-19.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDONavigationController : UIViewController <JDONavigationView>

@property (strong,nonatomic) JDONavigationView *navigationView;

- (void) setupNavigationView;

@end

//
//  JDOAppDelegate.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-10.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@class IIViewDeckController;

@interface JDOAppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) IIViewDeckController *deckController;

- (IIViewDeckController *)generateControllerStack;

@end

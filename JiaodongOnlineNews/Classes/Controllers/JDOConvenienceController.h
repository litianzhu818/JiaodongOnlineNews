//
//  JDOConvenienceController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-6.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusLauncher.h"
#import "JDOCenterViewController.h"
#import "JDOConvenienceItemController.h"

@interface JDOConvenienceController : NILauncherViewController <JDONavigationView>

@property (strong,nonatomic) JDONavigationView *navigationView;

@end

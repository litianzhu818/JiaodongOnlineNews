//
//  JDOCenterViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MenuItemNews = 0,
    MenuItemImage,
    MenuItemTopic,
    MenuItemConvenience,
    MenuItemLivehood,
    MenuItemCount
} MenuItem;

@class JDONewsViewController;
@class JDOImageViewController;

typedef enum {
    RootViewControllerNews,
    RootViewControllerImage,
    RootViewControllerTopic,
    
} RootViewControllerType;

@interface JDOCenterViewController : UINavigationController <IIViewDeckControllerDelegate,UIGestureRecognizerDelegate>

+ (JDONewsViewController *) sharedNewsViewController;
+ (JDOImageViewController *) sharedImageViewController;

- (void) setRootViewControllerType:(MenuItem) menuItem;

@end

//
//  JDOCenterViewController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLNavigationController.h"

typedef enum {
    MenuItemNews = 0,
    MenuItemParty,
    MenuItemImage,
    MenuItemTopic,
    MenuItemConvenience,
    MenuItemLivehood,
    MenuItemCount
} MenuItem;

@class JDONewsViewController;
@class JDOImageViewController;

@interface JDOCenterViewController : MLNavigationController <IIViewDeckControllerDelegate,UIGestureRecognizerDelegate>

+ (JDONewsViewController *) sharedNewsViewController;
+ (JDOImageViewController *) sharedImageViewController;

- (void) setRootViewControllerType:(MenuItem) menuItem;

- (void)pushViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated;

- (NSArray *)popToViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated complete:(void (^)()) complete;

@end

@protocol JDONavigationView

@required
@property (strong,nonatomic) JDONavigationView *navigationView;
- (void) setupNavigationView;

@end

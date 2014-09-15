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
    MenuItemVideo,
    MenuItemReport,
    MenuItemCount
} MenuItem;

@class JDONewsViewController;
@class JDOImageViewController;
@class JDOConvenienceController;
@class JDOTopicViewController;
@class JDOLivehoodViewController;
@class JDOPartyViewController;
@class JDOVideoViewController;
@class JDOReportViewController;

@interface JDOCenterViewController : MLNavigationController <IIViewDeckControllerDelegate,UIGestureRecognizerDelegate>

+ (JDONewsViewController *) sharedNewsViewController;
+ (JDOImageViewController *) sharedImageViewController;
+ (JDOConvenienceController *) sharedConvenienceController;
+ (JDOTopicViewController *) sharedTopicViewController;
+ (JDOLivehoodViewController *) sharedLivehoodViewController;
+ (JDOPartyViewController *) sharedPartyViewController;
+ (JDOVideoViewController *) sharedVideoViewController;
+ (JDOReportViewController *) sharedReportViewController;

@property (nonatomic,assign) MenuItem rootViewControllerType;

- (void)pushViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated;

- (NSArray *)popToViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController orientation:(JDOTransitionOrientation) orientation animated:(BOOL)animated complete:(void (^)()) complete;

@end

@protocol JDONavigationView

@required
@property (strong,nonatomic) JDONavigationView *navigationView;
- (void) setupNavigationView;

@end

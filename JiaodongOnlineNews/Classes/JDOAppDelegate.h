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
@property (strong, nonatomic) NSString *cachePath;
@property (strong, nonatomic) NSString *newsDetailCachePath;
@property (strong, nonatomic) NSString *imageDetailCachePath;
@property (strong, nonatomic) NSString *topicDetailCachePath;
@property (strong, nonatomic) NSString *partyDetailCachePath;
@property (strong, nonatomic) NSString *convenienceCachePath;

@property (assign, nonatomic) NSString * currentPushTag;

- (IIViewDeckController *)generateControllerStack;
- (void)checkForNewVersion;
- (void)promptForRating;

@end

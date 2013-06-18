//
//  JDOShareViewDelegate.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-17.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ISSShareViewDelegate.h>

@interface JDOShareViewDelegate : NSObject <ISSViewDelegate>

- (id) initWithBackBlock:(void (^)()) backBlock completeBlock:(void (^)()) completeBlock;

+ (JDOShareViewDelegate*) sharedDelegate;

@end

//
//  JDOChannelSetting.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-1-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOChannelItem.h"



@class JDOChannelSetting;

@protocol JDOChannelSettingDelegate

- (void)onSettingFinished:(BOOL) changed;

@end

@interface JDOChannelSetting : UIView <JDOChannelItemDelegate>

@property (nonatomic, assign) id<JDOChannelSettingDelegate> delegate;

@end

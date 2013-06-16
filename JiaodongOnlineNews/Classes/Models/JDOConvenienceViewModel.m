//
//  JDOConvenienceViewModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-7.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOConvenienceViewModel.h"
#import "NILauncherView.h"

@interface JDOConvenienceViewModel ()

@end

@implementation JDOConvenienceViewModel

- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page{
    return 9;
}

- (NSInteger)numberOfColumnsPerPageInLauncherView:(NILauncherView *)launcherView{
    return 3;
}

- (NSInteger)numberOfRowsPerPageInLauncherView:(NILauncherView *)launcherView{
    return 3;
}

@end

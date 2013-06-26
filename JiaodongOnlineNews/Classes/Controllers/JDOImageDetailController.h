//
//  JDOImageDetailController.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@class JDOImageModel;

@interface JDOImageDetailController : JDONavigationController <MWPhotoBrowserDelegate>

@property (nonatomic,strong) JDOImageModel *imageModel;

- (id)initWithImageModel:(JDOImageModel *)imageModel;

@end

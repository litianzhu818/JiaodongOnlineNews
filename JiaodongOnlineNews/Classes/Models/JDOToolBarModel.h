//
//  JDOShareModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-26.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JDOToolbarModel <NSObject>

@required
- (NSString *)id;
- (NSString *)title;
- (NSString *)summary;
- (NSString *)imageurl;
- (NSString *)reviewService;

@end

//
//  JDOArrayModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-15.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOArrayModel : NSObject

@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSArray *data;   // data的具体类型需要在解析json前通过config设置

@end

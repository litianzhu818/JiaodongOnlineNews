//
//  JDODataModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-14.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDODataModel : NSObject

@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSObject *data;   // data的具体类型需要在解析json前通过config设置

@end

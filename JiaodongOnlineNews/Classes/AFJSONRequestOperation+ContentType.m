//
//  AFJSONRequestOperation+ContentType.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

// ***********************************************
// ***********************************************
// ===================该类暂不使用==================
// ***********************************************
// ***********************************************

#import "AFJSONRequestOperation+ContentType.h"

@implementation AFJSONRequestOperation (ContentType)

// 覆盖该方法，因为服务器返回的response类型不标准(内容为json，声明为text/html)
+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"text/html", @"application/json", @"text/json", @"text/javascript", nil];
}

@end

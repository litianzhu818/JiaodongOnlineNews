//
//  JDOListDataModel.h
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-6-7.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^LoadDataSuccessBlock)(NSArray *dataList);
typedef void(^LoadDataFailureBlock)(NSString *errorStr);

#define Page_Size 20
@interface JDOListDataModel : NSObject
+(void)loadDataByServiceName:(NSString*)serviceName modelClass:(Class)modelClass pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;
@end

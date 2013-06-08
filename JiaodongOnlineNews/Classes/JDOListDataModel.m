//
//  JDOListDataModel.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-6-7.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOListDataModel.h"
#import "JDOWebClient.h"
@implementation JDOListDataModel
+(void)loadDataByServiceName:(NSString *)serviceName modelClass:(Class)modelClass pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    NSDictionary *param = @{@"p":[NSNumber numberWithInt:pageNum],@"pageSize":@Page_Size};
    
    // 取列表内容时，使用AFHTTPRequestOperation代替AFJSONRequestOperation，原因是服务器返回结果不规范，包括：
    // 1.服务器返回的response类型不标准(内容为json，声明为text/html)
    // 2.返回结果为空是，直接返回字符串的null,不符合json格式，无法被正确解析
    [[JDOHttpClient sharedClient] getPath:serviceName parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([@"null" isEqualToString:operation.responseString]){
            if(success)  success(nil);
        }else{
            NSArray *jsonArray = [(NSData *)responseObject objectFromJSONData];
            if(success)  success([jsonArray jsonArrayToModelArray:modelClass]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure) {
            failure([JDOCommonUtil formatErrorWithOperation:operation error:error]);
        }
    }];
}
@end

//
//  JDONewsModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsModel.h"
#import "JDOWebClient.h"

@implementation JDONewsModel

+ (void)loadHeadlineChannel:(NSString *)channel pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    NSDictionary *param = @{@"channelid":channel,@"pageSize":@NewsHead_Page_Size,@"atype":@"a"};
    
    [[JDOJsonClient sharedClient] getPath:NEWS_SERVICE parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonArray = (NSArray *)responseObject;
        if(success) {
            success([jsonArray jsonArrayToModelArray:self ]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure) {
           failure([JDOCommonUtil formatErrorWithOperation:operation error:error]);
        }
    }];
}

+ (void)loadNewsListChannel:(NSString *)channel pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure{
    
    NSDictionary *param = @{@"channelid":channel,@"p":[NSNumber numberWithInt:pageNum],@"pageSize":@NewsList_Page_Size,@"natype":@"a"};
    
    // 取列表内容时，使用AFHTTPRequestOperation代替AFJSONRequestOperation，原因是服务器返回结果不规范，包括：
    // 1.服务器返回的response类型不标准(内容为json，声明为text/html)
    // 2.返回结果为空是，直接返回字符串的null,不符合json格式，无法被正确解析
    [[JDOHttpClient sharedClient] getPath:NEWS_SERVICE parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([@"null" isEqualToString:operation.responseString]){
            if(success)  success(nil);
        }else{
            NSArray *jsonArray = [(NSData *)responseObject objectFromJSONData];
            if(success)  success([jsonArray jsonArrayToModelArray:self ]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure) {
            failure([JDOCommonUtil formatErrorWithOperation:operation error:error]);
        }
    }];
}

@end

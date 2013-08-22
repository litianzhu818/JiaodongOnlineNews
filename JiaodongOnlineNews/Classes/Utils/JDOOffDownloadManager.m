//
//  JDOOffDownloadManager.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-8-1.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOOffDownloadManager.h"
#import "JDONewsModel.h"
#import "JDOImageModel.h"
#import "JDOImageDetailModel.h"
#import "JDOTopicModel.h"
#import "JDORegxpUtil.h"
#import "SDImageCache.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"

#define Default_Head_Size 3
#define Default_News_Size 40
#define Default_Image_Size 10
#define Default_Topic_Size 10
#define Total_Size (Default_Head_Size+Default_News_Size)*5 + Default_Image_Size + Default_Topic_Size

@implementation JDOOffDownloadManager 

NSArray *channelArray;
NSArray *channelReuseIdArray;
id target;
SEL action;
int downloadCount;
SDWebImageManager *manager;
JDOJsonClient *httpClient;
NSMutableArray *operations;

- (NSDictionary *) newsListParamWithChannelIndex:(int)index{
    return @{@"channelid":[channelArray objectAtIndex:index],@"pageSize":@Default_News_Size,@"natype":@"a"};
}

- (NSDictionary *) headLineParamWithChannelIndex:(int)index{
    return @{@"channelid":[channelArray objectAtIndex:index],@"pageSize":@Default_Head_Size,@"atype":@"a"};
}

-(id) initWithTarget:(id)target1 action:(SEL)action1 {
    if (self = [super init]) {
        channelArray = @[@"16",@"7",@"11",@"12",@"13"];
        channelReuseIdArray = @[@"Local",@"Important",@"Social",@"Entertainment",@"Sport"];
        target = target1;
        action = action1;
        manager = [[SDWebImageManager alloc] init];
        operations = [[NSMutableArray alloc] init];
        httpClient = [[JDOJsonClient alloc] initWithBaseURL:[NSURL URLWithString:SERVER_QUERY_URL]];
    }
    [self startOffDownload];
    return self;
}

-(void) startOffDownload {
    downloadCount = 0;
    [self downloadNewsHeadWithChannelIndex:0];
}

-(void)cancelAll {
    [manager cancelAll];
    [httpClient.operationQueue cancelAllOperations];
}

-(void) findImageWithHtml:(NSString *) html {
    NSArray *imageUrls = [JDORegxpUtil getXmlTagAttrib: html andTag:@"img" andAttr:@"src"];
    for (int i=0; i<[imageUrls count]; i++) {
        NSString *realUrl = [imageUrls objectAtIndex:i];
        [self downloadImageWithUrl:realUrl];
    }
}

-(void) downloadImageWithUrl:(NSString *) realUrl {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:realUrl fromDisk:YES];
    if (!cachedImage) {
        [manager downloadWithURL:[NSURL URLWithString:realUrl] delegate:self];
    }
}

//下载新闻头条
-(void) downloadNewsHeadWithChannelIndex:(int) i{
    [self callBackToTargetWithTitle:@"正在下载新闻头条"];
    [operations removeAllObjects];
    [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:[self headLineParamWithChannelIndex:i] success:^(NSArray *dataList){
        if(dataList != nil && dataList.count >0){
            [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsHeadCache" stringByAppendingString:[channelReuseIdArray objectAtIndex:i]]]];
            for (JDONewsModel *newsModel in dataList) {
                NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString: newsModel.mpic];
                [self downloadImageWithUrl:realUrl];
                AFHTTPRequestOperation *operation = [httpClient createHTTPRequestOperationWithPath:NEWS_DETAIL_SERVICE parameters:@{@"aid":newsModel.id}  success:^(AFHTTPRequestOperation *operation, id responseObject){
                    [self findImageWithHtml:[responseObject objectForKey:@"content"]];
                    [self saveNewsDetailToLocalCache:responseObject];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                }];
                [operations addObject:operation];
            }
            [httpClient enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                downloadCount++;
                [self callBackToTarget];
            } completionBlock:^(NSArray *operations) {
                if (i==channelArray.count-1) {
                    [self downloadNewsListWithChannelIndex:0];
                } else {
                    [self downloadNewsHeadWithChannelIndex:i+1];
                }
            }];
        }
    } failure:^(NSString *error){
        [self callBackToTargetWithTitle:@"下载新闻头条失败"];
    }];
}

//下载新闻列表
-(void) downloadNewsListWithChannelIndex:(int) i{
    [self callBackToTargetWithTitle:@"正在下载新闻列表"];
    [operations removeAllObjects];
    [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:[self newsListParamWithChannelIndex:i] success:^(NSArray *dataList){
        if(dataList != nil && dataList.count >0){
            [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsListCache" stringByAppendingString:[channelReuseIdArray objectAtIndex:i]]]];
            for (JDONewsModel *newsModel in dataList) {
                NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString: newsModel.mpic];
                [self downloadImageWithUrl:realUrl];
                AFHTTPRequestOperation *operation = [httpClient createHTTPRequestOperationWithPath:NEWS_DETAIL_SERVICE parameters:@{@"aid":newsModel.id}  success:^(AFHTTPRequestOperation *operation, id responseObject){
                    [self findImageWithHtml:[responseObject objectForKey:@"content"]];
                    [self saveNewsDetailToLocalCache:responseObject];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                }];
                [operations addObject:operation];
            }
            [httpClient enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                downloadCount++;
                [self callBackToTarget];
            } completionBlock:^(NSArray *operations) {
                if (i==channelArray.count-1) {
                    [self downloadImageList];
                } else {
                    [self downloadNewsListWithChannelIndex:i+1];
                }
            }];
        }
    } failure:^(NSString *error){
        [self callBackToTargetWithTitle:@"下载新闻列表失败"];
    }];
}

//下载图片列表
-(void) downloadImageList{
    [self callBackToTargetWithTitle:@"正在下载图片列表"];
    [operations removeAllObjects];
    [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_SERVICE modelClass:@"JDOImageModel" params:@{@"pageSize":@Default_Image_Size} success:^(NSArray *dataList){
        if(dataList != nil && dataList.count >0){
            [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"ImageListCache"]];
            for (JDOImageModel *imageModel in dataList) {
                NSString *realUrl1 = [SERVER_RESOURCE_URL stringByAppendingString: imageModel.imageurl];
                [self downloadImageWithUrl:realUrl1];
                AFHTTPRequestOperation *operation = [httpClient createHTTPRequestOperationWithPath:IMAGE_DETAIL_SERVICE parameters:@{@"aid":imageModel.id}   success:^(AFHTTPRequestOperation *operation, id responseObject){
                    Class _modelClass = NSClassFromString(@"JDOImageDetailModel");
                    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass: _modelClass andConfiguration:[DCParserConfiguration configuration]];
                    NSArray *array = [mapper parseArray:responseObject];
                    for (JDOImageDetailModel *imageDetail in array) {
                        NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString:imageDetail.imageurl];
                        [self downloadImageWithUrl:realUrl];
                    }
                    [self saveImageDetailToLocalCache:array withId:imageModel.id];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                }];
                [operations addObject:operation];
            }
            [httpClient enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                downloadCount++;
                [self callBackToTarget];
            } completionBlock:^(NSArray *operations) {
                [self downloadTopicList];
            }];
        }
    }  failure:^(NSString *error){
        [self callBackToTargetWithTitle:@"下载图片列表失败"];
    }];
}

//下载话题列表
-(void) downloadTopicList{
    [self callBackToTargetWithTitle:@"正在下载话题列表"];
    [operations removeAllObjects];
    [[JDOJsonClient sharedClient] getJSONByServiceName:TOPIC_LIST_SERVICE modelClass:@"JDOTopicModel" params:@{@"pageSize":@Default_Topic_Size} success:^(NSArray *dataList){
        if(dataList != nil && dataList.count >0){
            [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"TopicListCache"]];
            for (JDOTopicModel *topicModel in dataList) {
                NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString: topicModel.imageurl];
                [self downloadImageWithUrl:realUrl];
                AFHTTPRequestOperation *operation = [httpClient createHTTPRequestOperationWithPath:TOPIC_DETAIL_SERVICE parameters:@{@"aid":topicModel.id}   success:^(AFHTTPRequestOperation *operation, id responseObject){
                    if([responseObject isKindOfClass:[NSDictionary class]]){
                        NSMutableDictionary *dict = [responseObject mutableCopy];
                        [dict setObject:topicModel.id forKey:@"id"];
                        [self findImageWithHtml:[dict objectForKey:@"content"]];
                        [self saveTopicDetailToLocalCache:dict];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                }];
                [operations addObject:operation];
            }
            [httpClient enqueueBatchOfHTTPRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                downloadCount++;
                [self callBackToTarget];
            } completionBlock:^(NSArray *operations) {
            }];
        }
    }  failure:^(NSString *error){
        [self callBackToTargetWithTitle:@"下载话题列表失败"];
    }];
}

-(void) callBackToTargetWithTitle:(NSString *)title {
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", nil];
    [target performSelectorOnMainThread:action withObject:result waitUntilDone:YES];
}

-(void) callBackToTargetWithCount:(NSNumber *) count {
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:count, @"count", nil];
    [target performSelectorOnMainThread:action withObject:result waitUntilDone:YES];
}

-(void) callBackToTarget {
    NSNumber *count = [NSNumber numberWithFloat:[[NSNumber numberWithInt:downloadCount] floatValue]/[[NSNumber numberWithInt:Total_Size] floatValue]];
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:count, @"count", nil];
    [target performSelectorOnMainThread:action withObject:result waitUntilDone:YES];
}

- (void) saveNewsDetailToLocalCache:(NSDictionary *) newsDetail{
    NSString *cacheFilePath = [[SharedAppDelegate newsDetailCachePath] stringByAppendingPathComponent:[@"NewDetail_" stringByAppendingString:[newsDetail objectForKey:@"id"]]];
    [NSKeyedArchiver archiveRootObject:newsDetail toFile:cacheFilePath];
}
- (void) saveImageDetailToLocalCache:(NSArray *) imageDetail withId:(NSString *)id{
    NSString *cacheFilePath = [[SharedAppDelegate imageDetailCachePath] stringByAppendingPathComponent:[@"ImageDetail_" stringByAppendingString:id]];
    [NSKeyedArchiver archiveRootObject:imageDetail toFile:cacheFilePath];
}
- (void) saveTopicDetailToLocalCache:(NSDictionary *) topicDetail{
    NSString *cacheFilePath = [[SharedAppDelegate topicDetailCachePath] stringByAppendingPathComponent:[@"TopicDetail_" stringByAppendingString:[topicDetail objectForKey:@"id"]]];
    [NSKeyedArchiver archiveRootObject:topicDetail toFile:cacheFilePath];
}
@end

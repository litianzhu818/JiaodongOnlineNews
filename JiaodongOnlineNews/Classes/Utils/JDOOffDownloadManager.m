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

#define Default_Head_Size 3
#define Default_News_Size 20
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

- (NSDictionary *) newsListParamWithChannelIndex:(int)index{
    return @{@"channelid":[channelArray objectAtIndex:index],@"pageSize":@Default_News_Size,@"natype":@"a"};
}

- (NSDictionary *) headLineParamWithChannelIndex:(int)index{
    return @{@"channelid":[channelArray objectAtIndex:index],@"pageSize":@Default_Head_Size,@"atype":@"a"};
}

-(void) start {
    [self startOffDownload];
}

-(BOOL)isConcurrent{
    //返回yes表示支持异步调用，否则为支持同步调用
    return YES;
    
}
- (BOOL)isExecuting {
    return target == nil;
}
- (BOOL)isFinished {
    return downloadCount == Total_Size;
}

-(id) initWithTarget:(id)target1 action:(SEL)action1 {
    if (self = [super init]) {
        target = target1;
        action = action1;
        manager = [[SDWebImageManager alloc] init];
    }
    return self;
}

-(void) startOffDownload {
    channelArray = @[@"16",@"7",@"11",@"12",@"13"];
    channelReuseIdArray = @[@"Local",@"Important",@"Social",@"Entertainment",@"Sport"];
    downloadCount = 0;
    [self downloadNewsHead];
    [self downloadNewsList];
    [self downloadImageList];
    [self downloadTopicList];
}

-(void)cancelAll {
    [self cancel];
    [manager cancelAll];
}

-(void) findImageWithHtml:(NSString *) html {
    if (![self isCancelled]) {
        NSArray *imageUrls = [JDORegxpUtil getXmlTagAttrib: html andTag:@"img" andAttr:@"src"];
        for (int i=0; i<[imageUrls count]; i++) {
            NSString *realUrl = [imageUrls objectAtIndex:i];
            UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:realUrl fromDisk:YES];
            if (!cachedImage) {
                [manager downloadWithURL:[NSURL URLWithString:realUrl] delegate:self];
            }
        }
    }
}

-(void) downloadImageWithUrl:(NSString *) realUrl {
    if (![self isCancelled]) {
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:realUrl fromDisk:YES];
        if (!cachedImage) {
            [manager downloadWithURL:[NSURL URLWithString:realUrl] delegate:self];
        }
    }
}

//下载新闻头条
-(void) downloadNewsHead{
    for (int i = 0; i<channelArray.count; i++) {
        [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:[self headLineParamWithChannelIndex:i] success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsHeadCache" stringByAppendingString:[channelReuseIdArray objectAtIndex:i]]]];
                for (JDONewsModel *newsModel in dataList) {
                    if (![self isCancelled]) {
                        NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString: newsModel.mpic];
                        [self downloadImageWithUrl:realUrl];
                        [[JDOJsonClient sharedClient] getPath:NEWS_DETAIL_SERVICE parameters:@{@"aid":newsModel.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            if([responseObject isKindOfClass:[NSDictionary class]]){
                                [self findImageWithHtml:[responseObject objectForKey:@"content"]];
                                [self saveNewsDetailToLocalCache:responseObject];
                            }
                            [self callBackToTarget];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [self callBackToTarget];
                        }];
                    }
                }
            }
            [self callBackToTargetWithTitle:@"正在下载新闻"];
        } failure:^(NSString *errorStr) {
            [self callBackToTargetWithTitle:@"下载新闻头条失败"];
        }];
    }
}

//下载新闻列表
-(void) downloadNewsList{
    for (int i = 0; i<channelArray.count; i++) {
        [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:[self newsListParamWithChannelIndex:i] success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsListCache" stringByAppendingString:[channelReuseIdArray objectAtIndex:i]]]];
                for (JDONewsModel *newsModel in dataList) {
                    if (![self isCancelled]) {
                        NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString: newsModel.mpic];
                        [self downloadImageWithUrl:realUrl];
                        [[JDOJsonClient sharedClient] getPath:NEWS_DETAIL_SERVICE parameters:@{@"aid":newsModel.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            if([responseObject isKindOfClass:[NSDictionary class]]){
                                [self findImageWithHtml:[responseObject objectForKey:@"content"]];
                                [self saveNewsDetailToLocalCache:responseObject];
                            }
                            [self callBackToTarget];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [self callBackToTarget];
                        }];
                    }
                }
            }
            [self callBackToTargetWithTitle:@"正在下载新闻"];
        } failure:^(NSString *errorStr) {
            [self callBackToTargetWithTitle:@"下载新闻列表失败"];
        }];
    }
}

//下载图片列表
-(void) downloadImageList{
        [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_SERVICE modelClass:@"JDOImageModel" params:@{@"pageSize":@Default_Image_Size} success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"ImageListCache"]];
                for (JDOImageModel *imageModel in dataList) {
                    if (![self isCancelled]) {
                        NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString: imageModel.imageurl];
                        [self downloadImageWithUrl:realUrl];
                        [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_DETAIL_SERVICE modelClass:@"JDOImageDetailModel" params:@{@"aid":imageModel.id} success:^(NSArray *dataList) {
                            for (JDOImageDetailModel *imageDetail in dataList) {
                                NSString *realUrl = [imageDetail.tinyurl stringByAppendingString: imageDetail.imageurl];
                                [self downloadImageWithUrl:realUrl];
                            }
                            [self saveImageDetailToLocalCache:dataList withId:imageModel.id];
                            [self callBackToTarget];
                        } failure:^(NSString *errorStr) {
                            [self callBackToTarget];
                        }];
                    }
                }
            }
            [self callBackToTargetWithTitle:@"正在下载图片"];
        } failure:^(NSString *errorStr) {
            [self callBackToTargetWithTitle:@"下载图片列表失败"];
        }];
}

//下载话题列表
-(void) downloadTopicList{
        [[JDOJsonClient sharedClient] getJSONByServiceName:TOPIC_LIST_SERVICE modelClass:@"JDOTopicModel" params:@{@"pageSize":@Default_Topic_Size} success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"TopicListCache"]];
                for (JDOTopicModel *topicModel in dataList) {
                    if (![self isCancelled]) {
                        NSString *realUrl = [SERVER_RESOURCE_URL stringByAppendingString: topicModel.imageurl];
                        [self downloadImageWithUrl:realUrl];
                        [[JDOJsonClient sharedClient] getPath:TOPIC_DETAIL_SERVICE parameters:@{@"aid":topicModel.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            if([responseObject isKindOfClass:[NSDictionary class]]){
                                NSMutableDictionary *dict = [responseObject mutableCopy];
                                [dict setObject:topicModel.id forKey:@"id"];
                                [self findImageWithHtml:[dict objectForKey:@"content"]];
                                [self saveTopicDetailToLocalCache:dict];
                            }
                            [self callBackToTarget];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [self callBackToTarget];
                        }];
                    }
                }
            }
            [self callBackToTargetWithTitle:@"正在下载话题"];
        } failure:^(NSString *errorStr) {
            [self callBackToTargetWithTitle:@"下载话题列表失败"];
        }];
}

-(void) callBackToTargetWithTitle:(NSString *)title {
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", nil];
    [target performSelectorOnMainThread:action withObject:result waitUntilDone:YES];
}

-(void) callBackToTarget {
    NSNumber *count = [NSNumber numberWithFloat:[[NSNumber numberWithInt:++downloadCount] floatValue]/[[NSNumber numberWithInt:Total_Size] floatValue]];
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:count, @"count", nil];
    [target performSelectorOnMainThread:action withObject:result waitUntilDone:YES];
}

// 保存列表内容至本地缓存文件
- (void) saveListToLocalCacheWithArray:(NSArray *)dataList andCacheFileName:(NSString *) cacheFileName{
    [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:cacheFileName]];
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

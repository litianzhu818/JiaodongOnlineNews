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
#import "JDOTopicModel.h"

#define Default_Head_Size 3
#define Default_News_Size 20
#define Default_Image_Size 10
#define Default_Topic_Size 10

@implementation JDOOffDownloadManager

NSArray *channelArray;
NSArray *channelReuseIdArray;

- (NSDictionary *) newsListParamWithChannelIndex:(int)index{
    return @{@"channelid":[channelArray objectAtIndex:index],@"pageSize":@Default_News_Size,@"natype":@"a"};
}

- (NSDictionary *) headLineParamWithChannelIndex:(int)index{
    return @{@"channelid":[channelArray objectAtIndex:index],@"pageSize":@Default_Head_Size,@"atype":@"a"};
}

-(void) startOffDownload {
    channelArray = @[@"16",@"7",@"11",@"12",@"13"];
    channelReuseIdArray = @[@"Local",@"Important",@"Social",@"Entertainment",@"Sport"];
    [self downloadNewsHead];
    [self downloadNewsList];
    [self downloadImageList];
    [self downloadTopicList];
}

//下载新闻头条
-(void) downloadNewsHead{
    for (int i = 0; i<channelArray.count; i++) {
        [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:[self headLineParamWithChannelIndex:i] success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsHeadCache" stringByAppendingString:[channelReuseIdArray objectAtIndex:i]]]];
                for (JDONewsModel *newsModel in dataList) {
                    
                }
            }
        } failure:^(NSString *errorStr) {
        }];
    }
}

//下载新闻列表
-(void) downloadNewsList{
    for (int i = 0; i<channelArray.count; i++) {
        [[JDOJsonClient sharedClient] getJSONByServiceName:NEWS_SERVICE modelClass:@"JDONewsModel" params:[self headLineParamWithChannelIndex:i] success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:[@"NewsListCache" stringByAppendingString:[channelReuseIdArray objectAtIndex:i]]]];
                for (JDONewsModel *newsModel in dataList) {
                    
                }
            }
        } failure:^(NSString *errorStr) {
        }];
    }
}

//下载图片列表
-(void) downloadImageList{
    for (int i = 0; i<channelArray.count; i++) {
        [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_SERVICE modelClass:@"JDOImageModel" params:@{@"pageSize":@Default_Image_Size} success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"ImageListCache"]];
                for (JDOImageModel *imageModel in dataList) {
                    
                }
            }
        } failure:^(NSString *errorStr) {
        }];
    }
}

//下载话题列表
-(void) downloadTopicList{
    for (int i = 0; i<channelArray.count; i++) {
        [[JDOJsonClient sharedClient] getJSONByServiceName:TOPIC_LIST_SERVICE modelClass:@"JDOTopicModel" params:@{@"pageSize":@Default_Topic_Size} success:^(NSArray *dataList) {
            if(dataList != nil && dataList.count >0){
                [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"TopicListCache"]];
                for (JDOTopicModel *topicModel in dataList) {
                    
                }
            }
        } failure:^(NSString *errorStr) {
        }];
    }
}

// 保存列表内容至本地缓存文件
- (void) saveListToLocalCacheWithArray:(NSArray *)dataList andCacheFileName:(NSString *) cacheFileName{
    [NSKeyedArchiver archiveRootObject:dataList toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:cacheFileName]];
}
@end

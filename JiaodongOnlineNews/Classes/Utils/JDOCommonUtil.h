//
//  JDOCommonUtil.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import "WBNoticeView.h"

#define PROTOCOL	@"PROTOCOL"
#define HOST		@"HOST"
#define PARAMS		@"PARAMS"
#define URI			@"URI"

typedef enum{
    DateFormatYMD,
    DateFormatMD,
    DateFormatYMDHM,
    DateFormatMDHM
}DateFormatType;

@interface JDOCommonUtil : NSObject

+ (void) showFrameDetail:(UIView *)view;
+ (void) showBoundsDetail:(UIView *)view;

+ (NSString *)formatDate:(NSDate *) date withFormatter:(DateFormatType) format;
+ (NSDate *)formatString:(NSString *)date withFormatter:(DateFormatType) format;
+ (NSString*)getChineseCalendarWithDate:(NSDate *)date;

+ (NSString *) formatErrorWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error;

+ (NSDictionary *)paramsFromURL:(NSString *)url;

+ (NSURL *)documentsDirectoryURL;
+ (NSURL *)cachesDirectoryURL;
+ (NSURL *)downloadsDirectoryURL;
+ (NSURL *)libraryDirectoryURL;
+ (NSURL *)applicationSupportDirectoryURL;

+ (BOOL) createDiskDirectory:(NSString *)directoryPath;
+ (NSString *) createJDOCacheDirectory;
+ (void) deleteJDOCacheDirectory;
+ (void) deleteURLCacheDirectory;
+ (int) getDiskCacheFileCount;
+ (int) getDiskCacheFileSize;

+ (void) showHintHUD:(NSString *)content inView:(UIView *)view;
+ (void) showHintHUD:(NSString *)content inView:(UIView *)view withSlidingMode:(WBNoticeViewSlidingMode)slidingMode;
+ (void) showHintHUD:(NSString *)content inView:(UIView *)view originY:(CGFloat) originY;
+ (void) showSuccessHUD:(NSString *)content inView:(UIView *)view;
+ (void) showSuccessHUD:(NSString *)content inView:(UIView *)view originY:(CGFloat) originY;

+ (BOOL)ifNoImage;

+ (NSMutableArray *)getShareTypes;
+ (NSMutableArray *)getAuthList;

@end

BOOL JDOIsEmptyString(NSString *string);
BOOL JDOIsNumber(NSString *string);
BOOL JDOIsEmail(NSString *string);
BOOL JDOIsVisiable(UIView *view);

NSString* JDOGetHomeFilePath(NSString *fileName);
NSString* JDOGetTmpFilePath(NSString *fileName);
NSString* JDOGetCacheFilePath(NSString *fileName);
NSString* JDOGetDocumentFilePath(NSString *fileName);
NSString* JDOGetUUID();

id<ISSAuthOptions> JDOGetOauthOptions(id<ISSViewDelegate> viewDelegate);

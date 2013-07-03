//
//  JDOCommonUtil.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

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

+ (void) showHintHUD:(NSString *)content inView:(UIView *)view;

@end

BOOL JDOIsEmptyString(NSString *string);
NSString* JDOGetHomeFilePath(NSString *fileName);
NSString* JDOGetTmpFilePath(NSString *fileName);
NSString* JDOGetUUID();

id<ISSAuthOptions> JDOGetOauthOptions(id<ISSViewDelegate> viewDelegate);

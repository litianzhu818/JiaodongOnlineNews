//
//  JDOCommonUtil.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCommonUtil.h"

@implementation JDOCommonUtil

static NSDateFormatter *dateFormatter;

+ (void) showFrameDetail:(UIView *)view{
    NSLog(@"x:%g,y:%g,w:%g,h:%g",view.frame.origin.x,view.frame.origin.y,
          view.frame.size.width,view.frame.size.height);
}
+ (void) showBoundsDetail:(UIView *)view{
    NSLog(@"x:%g,y:%g,w:%g,h:%g",view.bounds.origin.x,view.bounds.origin.y,
          view.bounds.size.width,view.bounds.size.height);
}


+ (NSString *)formatDate:(NSDate *) date withFormatter:(DateFormatType) format{
    if(dateFormatter == nil){
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    NSString *formatString;
    switch (format) {
        case DateFormatYMD:    formatString = @"yyyy/MM/dd";  break;
        case DateFormatMD:     formatString = @"MM/dd";  break;
        case DateFormatYMDHM:  formatString = @"yyyy/MM/dd HH:mm";  break;
        case DateFormatMDHM:   formatString = @"MM/dd HH:mm";  break;
        default:    break;
    }
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter stringFromDate:date];
}
+ (NSDate *)formatString:(NSString *)date withFormatter:(DateFormatType) format{
    if(dateFormatter == nil){
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    NSString *formatString;
    switch (format) {
        case DateFormatYMD:    formatString = @"yyyy/MM/dd";  break;
        case DateFormatMD:     formatString = @"MM/dd";  break;
        case DateFormatYMDHM:  formatString = @"yyyy/MM/dd HH:mm";  break;
        case DateFormatMDHM:   formatString = @"MM/dd HH:mm";  break;
        default:    break;
    }
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter dateFromString:date];
}

+ (NSString *) formatErrorWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error{
    NSString *errorStr ;
    if(operation.response.statusCode != 200){
        errorStr = [@"服务器端错误:" stringByAppendingString:[NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode]];
    }else{
        errorStr = error.domain;
    }
    return errorStr;
}

+ (NSDictionary *)paramsFromURL:(NSString *)url {
    
	NSString *protocolString = [url substringToIndex:([url rangeOfString:@"://"].location)];
    
	NSString *tmpString = [url substringFromIndex:([url rangeOfString:@"://"].location + 3)];
	NSString *hostString = nil;
    
	if (0 < [tmpString rangeOfString:@"/"].length) {
		hostString = [tmpString substringToIndex:([tmpString rangeOfString:@"/"].location)];
	}
	else if (0 < [tmpString rangeOfString:@"?"].length) {
		hostString = [tmpString substringToIndex:([tmpString rangeOfString:@"?"].location)];
	}
	else {
		hostString = tmpString;
	}
    
	tmpString = [url substringFromIndex:([url rangeOfString:hostString].location + [url rangeOfString:hostString].length)];
	NSString *uriString = @"/";
	if (0 < [tmpString rangeOfString:@"/"].length) {
		if (0 < [tmpString rangeOfString:@"?"].length) {
			uriString = [tmpString substringToIndex:[tmpString rangeOfString:@"?"].location];
		}
		else {
			uriString = tmpString;
		}
	}
    
	NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
	if (0 < [url rangeOfString:@"?"].length) {
		NSString *paramString = [url substringFromIndex:([url rangeOfString:@"?"].location + 1)];
		NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&amp;;"];
		NSScanner* scanner = [[NSScanner alloc] initWithString:paramString];
		while (![scanner isAtEnd]) {
			NSString* pairString = nil;
			[scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
			[scanner scanCharactersFromSet:delimiterSet intoString:NULL];
			NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
			if (kvPair.count == 2) {
				NSString* key = [[kvPair objectAtIndex:0]
								 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSString* value = [[kvPair objectAtIndex:1]
								   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				[pairs setObject:value forKey:key];
			}
		}
	}
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
			pairs, PARAMS,
			protocolString, PROTOCOL,
			hostString, HOST,
			uriString, URI, nil];
}

//NSFileManager* fm=[NSFileManager defaultManager];
//if(![fm fileExistsAtPath:[self dataFilePath]]){
//
//    //下面是对该文件进行制定路径的保存
//    [fm createDirectoryAtPath:[self dataFilePath] withIntermediateDirectories:YES attributes:nil error:nil];
//
//    //取得一个目录下得所有文件名
//    NSArray *files = [fm subpathsAtPath: [self dataFilePath] ];
//
//    //读取某个文件
//    NSData *data = [fm contentsAtPath:[self dataFilePath]];
//
//    //或者
//    NSData *data = [NSData dataWithContentOfPath:[self dataFilePath]];
//}
+ (NSURL *)documentsDirectoryURL {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


+ (NSURL *)cachesDirectoryURL {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)downloadsDirectoryURL {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask] lastObject];
}


+ (NSURL *)libraryDirectoryURL {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}


+ (NSURL *)applicationSupportDirectoryURL {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

BOOL JDOIsEmptyString(NSString *string) {
    return string == NULL || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || string.length == 0;
}
NSString* JDOGetHomeFilePath(NSString *fileName){
    return [NSHomeDirectory() stringByAppendingPathComponent:fileName];
}
NSString* JDOGetTmpFilePath(NSString *fileName){
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

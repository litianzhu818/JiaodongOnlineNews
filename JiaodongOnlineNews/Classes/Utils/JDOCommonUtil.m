//
//  JDOCommonUtil.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCommonUtil.h"
#import "JDOShareViewDelegate.h"

#define NUMBERS @"0123456789"

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

+ (NSString *) formatErrorWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error{
    NSString *errorStr ;
    if(operation.response.statusCode != 200){
        errorStr = [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode];
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

#pragma mark - 日期相关

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

+(NSString*)getChineseCalendarWithDate:(NSDate *)date{
    
    NSArray *chineseYears = [NSArray arrayWithObjects:
                             @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                             @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                             @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                             @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                             @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                             @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    
    NSArray *chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"冬月", @"腊月", nil];
    
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    
    NSString *chineseCal_str =[NSString stringWithFormat: @"%@%@%@",y_str,m_str,d_str];
    
    return chineseCal_str;
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

#pragma mark - 路径相关

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

#pragma mark - 提示窗口

+ (void) showHintHUD:(NSString *)content inView:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = content;
    hud.margin = 10.f;
    hud.yOffset = view.frame.size.height/2.0f-40;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

@end

BOOL JDOIsEmptyString(NSString *string) {
    return string == NULL || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || string.length == 0;
}
BOOL JDOIsNumber(NSString *string){
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    return basicTest;
}
BOOL JDOIsEmail(NSString *string){
    NSString *Regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *Test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [Test evaluateWithObject:string];
}
NSString* JDOGetHomeFilePath(NSString *fileName){
    return [NSHomeDirectory() stringByAppendingPathComponent:fileName];
}
NSString* JDOGetTmpFilePath(NSString *fileName){
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}
NSString* JDOGetCacheFilePath(NSString *fileName){
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
}


NSString* JDOGetUUID(){
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//        [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }else{
//        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:@"YOUR_BUNDLE_SEED.com.yourcompany.userinfo"];
//        NSString *strUUID = [keychainItem objectForKey:(id)kSecValueData];
//        if ([strUUID isEqualToString:@""]){
//            CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
//            CFStringRef stringRef = CFUUIDCreateString (kCFAllocatorDefault,uuidRef);
//            strUUID = (__bridge_transfer NSString*)stringRef;
//            [keychainItem setObject:strUUID forKey:(id)kSecValueData];
//            CFRelease(uuidRef);
//            CFRelease(stringRef);
//        }
//        return strUUID;
        return @"";
    }
}

id<ISSAuthOptions> JDOGetOauthOptions(id<ISSViewDelegate> viewDelegate){
    id<ISSViewDelegate> _delegate;
    if( viewDelegate == nil){
        _delegate = [JDOShareViewDelegate sharedDelegate];
    }else{
        _delegate = viewDelegate;
    }
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:false
                                                         authViewStyle:SSAuthViewStyleModal
                                                          viewDelegate:_delegate
                                               authManagerViewDelegate:_delegate];
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:@{
        SHARE_TYPE_NUMBER(ShareTypeSinaWeibo):[ShareSDK userFieldWithType:SSUserFieldTypeName valeu:@"naiyi1984"],
        SHARE_TYPE_NUMBER(ShareTypeTencentWeibo):[ShareSDK userFieldWithType:SSUserFieldTypeName valeu:@"intotherainzy"]}];
    return authOptions;
}

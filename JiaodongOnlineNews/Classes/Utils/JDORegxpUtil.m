//
//  JDORegxpUtil.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-7-12.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDORegxpUtil.h"

@implementation JDORegxpUtil

+ (NSArray *) getXmlTagAttrib:(NSString *)xmlStr andTag:(NSString *)tag andAttr:(NSString *)attr {
    NSString *regxpForTag = [[@"<\\s*" stringByAppendingString:tag] stringByAppendingString:@"\\s+([^>]*)\\s*/>"];
    NSString *regxpForTagAttrib = [attr stringByAppendingString:@"=\"([^\"]+)\""];
    
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:regxpForTag options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:regxpForTagAttrib options:NSRegularExpressionCaseInsensitive error:nil];

    NSArray *matches =    nil;
    NSMutableArray *retArray =[[NSMutableArray alloc] init];
    matches = [regex1 matchesInString:xmlStr options:0 range:NSMakeRange(0, [xmlStr length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = [match range];
        NSString *subString = [xmlStr substringWithRange:range];
        NSTextCheckingResult *firstSubMatch = [regex2 firstMatchInString:subString options:0 range:NSMakeRange(0, [subString length])];
        NSRange subRange = [firstSubMatch rangeAtIndex:1];
        NSString *retString = [subString substringWithRange:subRange];
        [retArray addObject:retString];
    }
    return retArray;
}
@end

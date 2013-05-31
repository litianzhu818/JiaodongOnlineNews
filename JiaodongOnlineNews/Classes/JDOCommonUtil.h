//
//  JDOCommonUtil.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    HDSDateYMD,
    HDSDateMD,
    HDSDateYMDHM,
    HDSDateMDHM
}HDSDateFormat;

@interface JDOCommonUtil : NSObject

+ (void) showFrameDetail:(UIView *)view;
+ (void) showBoundsDetail:(UIView *)view;

+ (NSString *)formatDate:(NSDate *) date withFormatter:(HDSDateFormat) format;
+ (NSDate *)formatString:(NSString *)date withFormatter:(HDSDateFormat) format;

+ (UIColor *) colorFromString:(NSString *)colorString;
+ (UIColor *) colorFromString:(NSString *)colorString alpha:(CGFloat) alpha;

@end

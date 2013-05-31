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


+ (NSString *)formatDate:(NSDate *) date withFormatter:(HDSDateFormat) format{
    if(dateFormatter == nil){
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    NSString *formatString;
    switch (format) {
        case HDSDateYMD:    formatString = @"yyyy/MM/dd";  break;
        case HDSDateMD:     formatString = @"MM/dd";  break;
        case HDSDateYMDHM:  formatString = @"yyyy/MM/dd HH:mm";  break;
        case HDSDateMDHM:   formatString = @"MM/dd HH:mm";  break;
        default:    break;
    }
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter stringFromDate:date];
}
+ (NSDate *)formatString:(NSString *)date withFormatter:(HDSDateFormat) format{
    if(dateFormatter == nil){
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    NSString *formatString;
    switch (format) {
        case HDSDateYMD:    formatString = @"yyyy/MM/dd";  break;
        case HDSDateMD:     formatString = @"MM/dd";  break;
        case HDSDateYMDHM:  formatString = @"yyyy/MM/dd HH:mm";  break;
        case HDSDateMDHM:   formatString = @"MM/dd HH:mm";  break;
        default:    break;
    }
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter dateFromString:date];
}

+ (UIColor *) colorFromString:(NSString *)colorString{
    return [self colorFromString:colorString alpha:1.0f];
}
+ (UIColor *) colorFromString:(NSString *)colorString alpha:(CGFloat) alpha{
    return [UIColor colorWithRed:
            strtoul([[colorString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)/255.0f
        green:strtoul([[colorString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16)/255.0f
        blue:strtoul([[colorString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16)/255.0f
        alpha:alpha
    ];
}

@end

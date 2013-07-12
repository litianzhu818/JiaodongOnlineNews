//
//  JDOWeather1.h
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-7-10.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOWeather : NSObject <NSCoding, NSXMLParserDelegate>

@property (nonatomic, strong) NSString *weather;
@property (nonatomic, strong) NSString *temp_low;
@property (nonatomic, strong) NSString *temp_high;
@property (nonatomic, strong) NSString *wind;
@property (nonatomic,strong) NSXMLParser *parser;

- (id) initWithData: (NSDictionary *) data;
- (id) initWithParser:(NSXMLParser *) parser;
- (BOOL)parse;
+ (void) saveToFile:(JDOWeather *) weather;
+ (JDOWeather *) readFromFile;
@end

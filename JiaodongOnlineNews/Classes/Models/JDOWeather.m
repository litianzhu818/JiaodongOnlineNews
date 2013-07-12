//
//  JDOWeather1.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-7-10.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWeather.h"

#define Weather_Cache_Path [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"WeatherCache"]

@implementation JDOWeather

-(id)initWithData:(NSDictionary *)data {
    self.weather = [data objectForKey:@"weather"];
    self.temp_low = [data objectForKey:@"temp_low"];
    self.temp_high = [data objectForKey:@"temp_high"];
    self.wind = [data objectForKey:@"wind"];
    return self;
}

- (id) initWithParser:(NSXMLParser *)parser {
    if(self = [super init]){
        self.parser = parser;
        self.weather = [[NSString alloc] init];
        self.temp_low = [[NSString alloc] init];
        self.temp_high = [[NSString alloc] init];
        self.wind = [[NSString alloc] init];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.weather = [aDecoder decodeObjectForKey:@"weather"];
        self.temp_low = [aDecoder decodeObjectForKey:@"temp_low"];
        self.wind = [aDecoder decodeObjectForKey:@"wind"];
        self.temp_high = [aDecoder decodeObjectForKey:@"temp_high"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.temp_high forKey:@"temp_high"];
    [aCoder encodeObject:self.temp_low forKey:@"temp_low"];
    [aCoder encodeObject:self.wind forKey:@"wind"];
    [aCoder encodeObject:self.weather forKey:@"weather"];
}

- (BOOL)parse{
    return [self.parser parse];
}

+ (void) saveToFile:(JDOWeather *) weather{
    [NSKeyedArchiver archiveRootObject:weather toFile:Weather_Cache_Path];
}

+ (JDOWeather *) readFromFile{ 
    return [NSKeyedUnarchiver unarchiveObjectWithFile: Weather_Cache_Path];
}
@end

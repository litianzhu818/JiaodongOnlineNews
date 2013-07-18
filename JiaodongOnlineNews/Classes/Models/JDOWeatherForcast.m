//
//  JDOWeatherForcast.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWeatherForcast.h"

@implementation JDOWeatherForcast

- (id) init{
    if(self = [super init]){
        self.date = [[NSMutableString alloc] init];
        self.weatherDetail = [[NSMutableString alloc] init];
        self.temperature = [[NSMutableString alloc] init];
        self.wind = [[NSMutableString alloc] init];
        
        self.status = [[NSMutableString alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.weatherDetail = [aDecoder decodeObjectForKey:@"weatherDetail"];
        self.temperature = [aDecoder decodeObjectForKey:@"temperature"];
        self.wind = [aDecoder decodeObjectForKey:@"wind"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.weatherDetail forKey:@"weatherDetail"];
    [aCoder encodeObject:self.temperature forKey:@"temperature"];
    [aCoder encodeObject:self.wind forKey:@"wind"];
}

- (void)analysis{
    [self.date appendString: [[self.status componentsSeparatedByString:@" "] objectAtIndex:0]];
    [self.weatherDetail appendString: [[self.status componentsSeparatedByString:@" "] lastObject]];
}

@end

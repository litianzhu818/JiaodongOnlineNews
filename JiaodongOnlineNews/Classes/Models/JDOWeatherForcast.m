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

- (void)analysis{
    [self.date appendString: [[self.status componentsSeparatedByString:@" "] objectAtIndex:0]];
    [self.weatherDetail appendString: [[self.status componentsSeparatedByString:@" "] lastObject]];
}

@end

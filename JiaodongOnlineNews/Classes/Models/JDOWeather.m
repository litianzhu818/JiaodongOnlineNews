//
//  JDOWeather.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWeather.h"

@implementation JDOWeather

- (id) init{
    if(self = [super init]){
        self.province = [[NSMutableString alloc] init];
        self.city = [[NSMutableString alloc] init];
        self.district = [[NSMutableString alloc] init];
        self.cityCode = [[NSMutableString alloc] init];
        self.updateTime = [[NSMutableString alloc] init];
        self.date = [[NSMutableString alloc] init];
        self.currentTemperature = [[NSMutableString alloc] init];
        self.currentWind = [[NSMutableString alloc] init];
        self.currentHumidity = [[NSMutableString alloc] init];
        self.airQuality = [[NSMutableString alloc] init];
        self.ziwaixian = [[NSMutableString alloc] init];
        self.lifeSuggestion = [[NSMutableString alloc] init];
        self.forecast = [[NSMutableArray alloc] init];
        
        self.provinceAndCity = [[NSMutableString alloc] init];
        self.tempWindAndHum = [[NSMutableString alloc] init];
        self.airAndZiwaixian = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)analysis{
    // 解析省市
    if ([_provinceAndCity hasPrefix:@"查询结果为空"] || [_provinceAndCity hasPrefix:@"发现错误"]) {
        self.success = false;
        return ;
    }else{
        NSRange range = [_provinceAndCity rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        if(range.length > 0){
            [self.province appendString:[_provinceAndCity substringToIndex:range.location]];
            [self.city appendString:[_provinceAndCity substringFromIndex:range.location]];
        }else{
            [self.city appendString:_provinceAndCity];
        }
    }
    
    // 解析天气温度湿度
    NSArray *_ta = [[_tempWindAndHum substringFromIndex:7] componentsSeparatedByString:@"；"];
    [self.currentTemperature appendString:[[[_ta objectAtIndex:0] componentsSeparatedByString:@"："] lastObject]];
    [self.currentWind appendString: [[[_ta objectAtIndex:1] componentsSeparatedByString:@"："] lastObject]];
    [self.currentHumidity appendString: [[[_ta objectAtIndex:2] componentsSeparatedByString:@"："] lastObject]];
    
    // 解析空气质量紫外线
    NSArray *_aa = [_airAndZiwaixian componentsSeparatedByString:@"；"];
    [self.airQuality appendString: [[[_aa objectAtIndex:0] componentsSeparatedByString:@"："] lastObject]];
    [self.ziwaixian appendString: [[[_aa objectAtIndex:1] componentsSeparatedByString:@"："] lastObject]];

}


@end

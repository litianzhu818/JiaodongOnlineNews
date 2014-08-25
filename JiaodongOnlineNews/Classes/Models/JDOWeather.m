//
//  JDOWeather.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWeather.h"
#import "JDOWeatherForcast.h"

@interface JDOWeather ()

@property (strong) JDOWeatherForcast *forcast;

@end

@implementation JDOWeather{
    int xmlIndex;
}

- (id) initWithParser:(NSXMLParser *) parser{
    if(self = [super init]){
        self.parser = parser;
        self.parser.delegate = self;
        self.parser.shouldProcessNamespaces = true;
        
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

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.city = [aDecoder decodeObjectForKey:@"city"];
        self.updateTime = [aDecoder decodeObjectForKey:@"updateTime"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.currentTemperature = [aDecoder decodeObjectForKey:@"currentTemperature"];
        self.currentWind = [aDecoder decodeObjectForKey:@"currentWind"];
        self.currentHumidity = [aDecoder decodeObjectForKey:@"currentHumidity"];
        self.forecast = [aDecoder decodeObjectForKey:@"forecast"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.updateTime forKey:@"updateTime"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.currentTemperature forKey:@"currentTemperature"];
    [aCoder encodeObject:self.currentWind forKey:@"currentWind"];
    [aCoder encodeObject:self.currentHumidity forKey:@"currentHumidity"];
    [aCoder encodeObject:self.forecast forKey:@"forecast"];
}

- (BOOL)parse{
    return [self.parser parse];
}

- (void)analysis{
    // 解析省市
    if ([_provinceAndCity hasPrefix:@"查询结果为空"] || [_provinceAndCity hasPrefix:@"发现错误"] || [_provinceAndCity hasPrefix:@"系统维护"]) {
        self.success = false;
        return ;
    }
    
    NSRange range = [_provinceAndCity rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if(range.length > 0){
        [self.province appendString:[_provinceAndCity substringToIndex:range.location]];
        [self.city appendString:[_provinceAndCity substringFromIndex:range.location+1]];
    }else{
        [self.city appendString:_provinceAndCity];
    }
    
    // 解析天气温度湿度
#warning 有可能返回的内容是"暂无实况",此时的数组取值会造成越界,在外层的调用中捕获异常处理
    NSArray *_ta = [[_tempWindAndHum substringFromIndex:7] componentsSeparatedByString:@"；"];
    [self.currentTemperature appendString:[[[_ta objectAtIndex:0] componentsSeparatedByString:@"："] lastObject]];
    [self.currentWind appendString: [[[_ta objectAtIndex:1] componentsSeparatedByString:@"："] lastObject]];
    [self.currentHumidity appendString: [[[_ta objectAtIndex:2] componentsSeparatedByString:@"："] lastObject]];
    
    // 解析空气质量紫外线
    NSArray *_aa = [_airAndZiwaixian componentsSeparatedByString:@"；"];
    [self.airQuality appendString: [[[_aa objectAtIndex:0] componentsSeparatedByString:@"："] lastObject]];
    [self.ziwaixian appendString: [[[_aa objectAtIndex:1] componentsSeparatedByString:@"："] lastObject]];
}

+ (void) saveToFile:(JDOWeather *) weather{
    [NSKeyedArchiver archiveRootObject:weather toFile:[[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"WeatherCache"]];
}

+ (JDOWeather *) readFromFile{
    return [NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"WeatherCache"]];
}


#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    xmlIndex = 0;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    @try{   // analysis方法中曾出现过数组越界
        [self.forecast enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(JDOWeatherForcast *)obj analysis];
        }];
        [self analysis];
    }@catch(NSException *ex){
        self.success = false;
    }
    if(self.success){
        [JDOWeather saveToFile:self];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if([elementName isEqualToString:@"ArrayOfString"]){
        self.success = true;
        [self.date appendString:[[NSDate date] description]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"string"]){
        xmlIndex++;
        if((xmlIndex - 7) % 5 == 0){
            _forcast = [[JDOWeatherForcast alloc] init];
        }else if((xmlIndex - 7) % 5 == 4){
            [self.forecast addObject:_forcast];
        }
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        return ;
    }
    switch (xmlIndex) {
        case 0:// Array(0) = "省份 地区/洲 国家名（国外）"
            [self.provinceAndCity appendString:string];
            break;
        case 1:// Array(1) = "查询的天气预报地区名称"
            [self.district appendString:string];
            break;
        case 2:// Array(2) = "查询的天气预报地区ID"
            [self.cityCode appendString:string];
            break;
        case 3:// Array(3) = "最后更新时间 格式：yyyy-MM-dd HH:mm:ss"
            [self.updateTime appendString:string];;
            break;
        case 4:{// Array(4) = "当前天气实况：气温、风向/风力、湿度"
            [self.tempWindAndHum appendString:string];
            break;
        }
        case 5:{// Array(5) = "当前 空气质量、紫外线强度"
            [self.airAndZiwaixian appendString:string];
            break;
        }
        case 6:// Array(6) = "当前 天气和生活指数"
            [self.lifeSuggestion appendString:string];
            break;
        default:
            switch ((xmlIndex - 7) % 5) {
                case 0:// Array(n-4) = "第二天 概况 格式：M月d日 天气概况"
                    [_forcast.status appendString:string];
                    break;
                case 1:// Array(n-3) = "第二天 气温"
                    [_forcast.temperature appendString:string];
                    break;
                case 2:// Array(n-2) = "第二天 风力/风向"
                    [_forcast.wind appendString:string];
                    break;
                default:
                    break;
            }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@",parseError.localizedDescription);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError{
    NSLog(@"%@",validationError.localizedDescription);
}


@end

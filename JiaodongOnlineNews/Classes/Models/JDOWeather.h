//
//  JDOWeather.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOWeather : NSObject

@property (nonatomic,assign) BOOL success;
@property (nonatomic,strong) NSMutableString *province;
@property (nonatomic,strong) NSMutableString *city;/**城市，地级市或直辖市名*/
@property (nonatomic,strong) NSMutableString *district;/**地区。可能是地级市或城区*/
@property (nonatomic,strong) NSMutableString *cityCode;
@property (nonatomic,strong) NSMutableString *updateTime;/**最后更新时间 格式：yyyy-MM-dd HH:mm:ss*/
@property (nonatomic,strong) NSMutableString *date;/**哪一天的天气*/
@property (nonatomic,strong) NSMutableString *currentTemperature;/**当前天气气温*/
@property (nonatomic,strong) NSMutableString *currentWind;/**当前天气风力*/
@property (nonatomic,strong) NSMutableString *currentHumidity;/**当前天气湿度*/
@property (nonatomic,strong) NSMutableString *airQuality;/**空气质量*/
@property (nonatomic,strong) NSMutableString *ziwaixian;/**紫外线强度 */
@property (nonatomic,strong) NSMutableString *lifeSuggestion;/**生活指数*/
@property (nonatomic,strong) NSMutableArray *forecast;/**未来N天的天气预报，不包括当天*/

@property (nonatomic,strong) NSMutableString *provinceAndCity;
@property (nonatomic,strong) NSMutableString *tempWindAndHum;
@property (nonatomic,strong) NSMutableString *airAndZiwaixian;

- (void)analysis;

@end

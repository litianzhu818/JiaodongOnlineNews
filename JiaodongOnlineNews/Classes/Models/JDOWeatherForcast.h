//
//  JDOWeatherForcast.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOWeatherForcast : NSObject <NSCoding>

@property (nonatomic,strong) NSMutableString *date;/**哪一天的天气*/
@property (nonatomic,strong) NSMutableString *weatherDetail;/**天气概况 例如晴转多云 */
@property (nonatomic,strong) NSMutableString *temperature;/**温度  例如-4℃/11℃*/
@property (nonatomic,strong) NSMutableString *wind;/**风力和风向  例如北风3-4级转微风*/

@property (nonatomic,strong) NSMutableString *status;

- (void)analysis;

@end

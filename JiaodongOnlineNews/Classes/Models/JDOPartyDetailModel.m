//
//  JDOTopicDetailModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPartyDetailModel.h"
#import "ICUTemplateMatcher.h"

@implementation JDOPartyDetailModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.active_starttime = [aDecoder decodeObjectForKey:@"active_starttime"];
        self.active_endtime = [aDecoder decodeObjectForKey:@"active_endtime"];
        self.active_allowreg = [aDecoder decodeObjectForKey:@"active_allowreg"];
        self.active_regendtime = [aDecoder decodeObjectForKey:@"active_regendtime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.active_starttime forKey:@"active_starttime"];
    [aCoder encodeObject:self.active_endtime forKey:@"active_endtime"];
    [aCoder encodeObject:self.active_allowreg forKey:@"active_allowreg"];
    [aCoder encodeObject:self.active_regendtime forKey:@"active_regendtime"];
}

+ (NSString *) mergeToHTMLTemplateFromDictionary:(NSDictionary *)dictionary{
    MGTemplateEngine *engine = [[self class] sharedTemplateEngine];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"content_template" ofType:@"html"];
    
    // 默认字号从UserDefault获取 small_font,normal_font,big_font
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *fontClass = [userDefault objectForKey:@"font_class"];
    if(fontClass == nil){
        fontClass = @"normal_font";
        [userDefault setObject:fontClass forKey:@"font_class"];
        [userDefault synchronize];
    }
#warning 未处理重复投票
    NSMutableDictionary *variables = [[NSMutableDictionary alloc] init];
    [variables setValue:fontClass forKey:@"font_class"];
    [variables setValue:[dictionary objectForKey:@"active_allowreg"] forKey:@"hasJoin"];
    NSDate *starttime = [JDOCommonUtil formatString:[dictionary objectForKey:@"active_starttime"] withFormatter:DateFormatYMDHMS];
    NSDate *endtime = [JDOCommonUtil formatString:[dictionary objectForKey:@"active_endtime"] withFormatter:DateFormatYMDHMS];
    NSDate *regendtime = [JDOCommonUtil formatString:[dictionary objectForKey:@"active_regendtime"] withFormatter:DateFormatYMDHMS];
    
    NSDate *now = [NSDate date];
    NSString *joinBtnStr = nil;
    if ([now compare:starttime] == NSOrderedAscending) {
        joinBtnStr = @"报名尚未开始";
    } else if([now compare:endtime] == NSOrderedDescending){
        joinBtnStr = @"活动已经结束";
    } else if([now compare:regendtime] == NSOrderedDescending){
        joinBtnStr = @"报名已经结束";
    } else {
        joinBtnStr = @"我要报名";
    }
    [variables setValue:[dictionary objectForKey:@"active_starttime"] forKey:@"active_starttime"];
    [variables setValue:joinBtnStr forKey:@"joinBtnStr"];
    [variables addEntriesFromDictionary:dictionary];
    
    return [engine processTemplateInFileAtPath:templatePath withVariables:variables];
}

@end

//
//  JDOTopicDetailModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOTopicDetailModel.h"
#import "ICUTemplateMatcher.h"

@implementation JDOTopicDetailModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.issue = [aDecoder decodeObjectForKey:@"issue"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.points = [aDecoder decodeObjectForKey:@"points"];
        self.drawno = [aDecoder decodeObjectForKey:@"drawno"];
        self.voteCounts = [aDecoder decodeObjectForKey:@"voteCounts"];
        self.tinyurl = [aDecoder decodeObjectForKey:@"tinyurl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.issue forKey:@"issue"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.points forKey:@"points"];
    [aCoder encodeObject:self.drawno forKey:@"drawno"];
    [aCoder encodeObject:self.voteCounts forKey:@"voteCounts"];
    [aCoder encodeObject:self.tinyurl forKey:@"tinyurl"];
}


+ (MGTemplateEngine *) sharedTemplateEngine{
    static MGTemplateEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [MGTemplateEngine templateEngine] ;
    });
    return _sharedEngine;
}

+ (NSString *) mergeToHTMLTemplateFromDictionary:(NSMutableDictionary *)dictionary{
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
    [variables setValue:@"1" forKey:@"hasVote"];
    [variables setValue:[dictionary valueForKey:@"id"] forKey:@"id"];
    [variables setValue:[SERVER_QUERY_URL stringByAppendingString:VOTE_SERVICE] forKey:@"vote_addr"];
    if ([[dictionary objectForKey:@"showMore"] isEqualToString:@"1"]) {
        [variables setValue:@"1" forKey:@"showMoreTopic"];
    }
    [variables addEntriesFromDictionary:dictionary];
    
    return [engine processTemplateInFileAtPath:templatePath withVariables:variables];
}

- (void)templateEngine:(MGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo
{
	//NSLog(@"Started block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo
{
	//NSLog(@"Ended block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngineFinishedProcessingTemplate:(MGTemplateEngine *)engine
{
	//NSLog(@"Finished processing template.");
}


- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;
{
	NSLog(@"Template error: %@", error);
}

@end

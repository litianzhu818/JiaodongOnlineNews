//
//  JDONewsDetailModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsDetailModel.h"
#import "ICUTemplateMatcher.h"

@implementation JDONewsDetailModel

+ (MGTemplateEngine *) sharedTemplateEngine{
    static MGTemplateEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [MGTemplateEngine templateEngine] ;
    });
    return _sharedEngine;
}

+ (NSString *) mergeToHTMLTemplateFromDictionary:(NSDictionary *)dictionary{
    MGTemplateEngine *engine = [[self class] sharedTemplateEngine];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"news_template" ofType:@"html"];
    
    // 默认字号从UserDefault获取 small_font,normal_font,big_font
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *fontClass = [userDefault objectForKey:@"font_class"];
    if(fontClass == nil){
        fontClass = @"normal_font";
        [userDefault setObject:fontClass forKey:@"font_class"];
        [userDefault synchronize];
    }
    
    NSMutableDictionary *variables = [[NSMutableDictionary alloc] init];
    [variables setValue:fontClass forKey:@"font_class"];
    [variables addEntriesFromDictionary:dictionary];
    
    return [engine processTemplateInFileAtPath:templatePath withVariables:variables];
}

- (NSString *) mergeToHTMLTemplate{
    MGTemplateEngine *engine = [[self class] sharedTemplateEngine];
    [engine setDelegate:self];
    [engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"news_template" ofType:@"html"];
    
    NSMutableDictionary *variables = [[NSMutableDictionary alloc] init];
    NSDictionary *selfDictionary = @{@"title":self.title,@"content":self.content};
    [variables addEntriesFromDictionary:selfDictionary];
    
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

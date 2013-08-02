//
//  JDOTopicDetailModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "MGTemplateEngine.h"

@interface JDOTopicDetailModel : NSObject <NSCoding,MGTemplateEngineDelegate>

@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *date;
@property (nonatomic,copy) NSString *issue;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSArray  *points;
@property (nonatomic,copy) NSString *drawno;
@property (nonatomic,copy) NSString *voteCounts;
@property (nonatomic,copy) NSString *tinyurl;

+ (MGTemplateEngine *) sharedTemplateEngine;
+ (NSString *) mergeToHTMLTemplateFromDictionary:(NSDictionary *)dictionary;

@end

//
//  JDOTopicDetailModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-4.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "MGTemplateEngine.h"
#import "JDONewsDetailModel.h"

@interface JDOPartyDetailModel : JDONewsDetailModel

@property (nonatomic,copy) NSString *active_starttime;
@property (nonatomic,copy) NSString *active_endtime;
@property (nonatomic,copy) NSString *active_allowreg;
@property (nonatomic,copy) NSString *active_regendtime;

+ (NSString *) mergeToHTMLTemplateFromDictionary:(NSDictionary *)dictionary;
@end

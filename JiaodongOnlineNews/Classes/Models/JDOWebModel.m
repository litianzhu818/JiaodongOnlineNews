//
//  JDOWebModel.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-12-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWebModel.h"

@implementation JDOWebModel
-(id) initWithId:(NSString *)id andTitle:(NSString *)title andImageurl:(NSString *)imageurl andSummary:(NSString *)summary andTinyurl:(NSString *)tinyurl{
    self = [super init];
    if(self) {
        self.id = id;
        self.tinyurl = tinyurl;
        self.title = title;
        self.imageurl = imageurl;
        self.summary = summary;
    }
    return self;
}
@end

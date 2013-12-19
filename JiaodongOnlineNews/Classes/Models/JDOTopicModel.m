//
//  JDOTopicModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOTopicModel.h"

@implementation JDOTopicModel

- (NSString *) reviewService{
    return COMMIT_COMMENT_SERVICE;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.pubtime = [aDecoder decodeObjectForKey:@"pubtime"];
        self.summary = [aDecoder decodeObjectForKey:@"summary"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.follownums = [aDecoder decodeObjectForKey:@"follownums"];
        self.tinyurl = [aDecoder decodeObjectForKey:@"tinyurl"];
        self.imageurl = [aDecoder decodeObjectForKey:@"imageurl"];
        self.drawno = [aDecoder decodeObjectForKey:@"drawno"];
        self.modifytime = [aDecoder decodeObjectForKey:@"modifytime"];
    }
    return self;
}

- (id)initWithNewsModel:(JDONewsModel *)model
{
    if (self = [super init]) {
        self.id = model.id;
        self.title = model.title;
        self.pubtime = model.pubtime;
        //self.follownums = model.follownums;
        self.tinyurl = model.tinyurl;
        self.imageurl = model.imageurl;
        self.summary = model.summary;
        //self.drawno = model.drawno;
        self.showMore = @"show";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.pubtime forKey:@"pubtime"];
    [aCoder encodeObject:self.summary forKey:@"summary"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.follownums forKey:@"follownums"];
    [aCoder encodeObject:self.tinyurl forKey:@"tinyurl"];
    [aCoder encodeObject:self.imageurl forKey:@"imageurl"];
    [aCoder encodeObject:self.drawno forKey:@"drawno"];
    [aCoder encodeObject:self.modifytime forKey:@"modifytime"];
}

@end

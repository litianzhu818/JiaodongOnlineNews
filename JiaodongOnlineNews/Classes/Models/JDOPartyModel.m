//
//  JDOTopicModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-2.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPartyModel.h"

@implementation JDOPartyModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.pubtime = [aDecoder decodeObjectForKey:@"pubtime"];
        self.clicknum = [aDecoder decodeObjectForKey:@"clicknum"];
        self.summary = [aDecoder decodeObjectForKey:@"summary"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.mpic = [aDecoder decodeObjectForKey:@"mpic"];
        self.modifytime = [aDecoder decodeObjectForKey:@"modifytime"];
        self.active_starttime = [aDecoder decodeObjectForKey:@"active_starttime"];
        self.active_endtime = [aDecoder decodeObjectForKey:@"active_endtime"];
        self.active_address = [aDecoder decodeObjectForKey:@"active_address"];
    }
    return self;
}

- (id)initWithNewsModel:(JDONewsModel *)model
{
    if (self = [super init]) {
        self.id = model.id;
        self.title = model.title;
        self.pubtime = model.pubtime;
        self.tinyurl = model.tinyurl;
        self.imageurl = model.imageurl;
        self.summary = model.summary;
        self.clicknum = model.clicknum;
        self.modifytime = model.modifytime;
        self.mpic = model.mpic;
        //self.active_address = model.active_address;
        //self.active_endtime = model.active_endtime;
        //self.active_starttime = model.active_starttime;
        self.showMore = @"show";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.pubtime forKey:@"pubtime"];
    [aCoder encodeObject:self.summary forKey:@"summary"];
    [aCoder encodeObject:self.clicknum forKey:@"clicknum"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.mpic forKey:@"mpic"];
    [aCoder encodeObject:self.modifytime forKey:@"modifytime"];
    [aCoder encodeObject:self.active_starttime forKey:@"active_starttime"];
    [aCoder encodeObject:self.active_endtime forKey:@"active_endtime"];
    [aCoder encodeObject:self.active_address forKey:@"active_address"];
}

- (NSString *) imageurl{
    return self.mpic;
}

@end

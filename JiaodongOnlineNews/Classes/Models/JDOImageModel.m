//
//  JDOImageModel.m
//  JiaodongOnlineNews
//
//  Created by 陈鹏 on 13-6-7.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageModel.h"

@implementation JDOImageModel

- (NSString *) reviewService{
    return @"";
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
}

@end

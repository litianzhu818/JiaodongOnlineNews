//
//  JDONewsModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsModel.h"
#import "JDOWebClient.h"

@implementation JDONewsModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.atype = [aDecoder decodeObjectForKey:@"atype"];
        self.clicknum = [aDecoder decodeObjectForKey:@"clicknum"];
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.mpic = [aDecoder decodeObjectForKey:@"mpic"];
        self.pubtime = [aDecoder decodeObjectForKey:@"pubtime"];
        self.summary = [aDecoder decodeObjectForKey:@"summary"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.spic = [aDecoder decodeObjectForKey:@"spic"];
        self.modifytime = [aDecoder decodeObjectForKey:@"modifytime"];
        self.read = [aDecoder decodeBoolForKey:@"read"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.atype forKey:@"atype"];
    [aCoder encodeObject:self.clicknum forKey:@"clicknum"];
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.mpic forKey:@"mpic"];
    [aCoder encodeObject:self.pubtime forKey:@"pubtime"];
    [aCoder encodeObject:self.summary forKey:@"summary"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.spic forKey:@"spic"];
    [aCoder encodeObject:self.modifytime forKey:@"modifytime"];
    [aCoder encodeBool:self.read forKey:@"read"];
}

- (NSString *) imageurl{
    return self.mpic;
}

- (NSString *) reviewService{
    return COMMIT_COMMENT_SERVICE;
}
@end

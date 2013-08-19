//
//  JDOImageDetailModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageDetailModel.h"

@implementation JDOImageDetailModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.imageurl = [aDecoder decodeObjectForKey:@"imageurl"];
        self.imagecontent = [aDecoder decodeObjectForKey:@"imagecontent"];
        self.localUrl = [aDecoder decodeObjectForKey:@"localUrl"];
        self.tinyurl = [aDecoder decodeObjectForKey:@"tinyurl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.imageurl forKey:@"imageurl"];
    [aCoder encodeObject:self.imagecontent forKey:@"imagecontent"];
    [aCoder encodeObject:self.localUrl forKey:@"localUrl"];
    [aCoder encodeObject:self.tinyurl forKey:@"tinyurl"];
}
- (id) initWithUrl:(NSString *) imageUrl andContent:(NSString *)imageContent {
    if(self = [super init]){
        self.imagecontent = imageContent;
        self.imageurl = imageUrl;
    }
    return self;
}
- (id) initWithUrl:(NSString *) imageUrl andLocalUrl:(NSString *)localUrl andContent:(NSString *)imageContent andTitle:(NSString *) title andTinyUrl:(NSString *)tinyUrl{
    if(self = [super init]){
        self.localUrl = localUrl;
        self.imagecontent = imageContent;
        self.imageurl = imageUrl;
        self.title = title;
        self.tinyurl = tinyUrl;
    }
    return self;
}
@end

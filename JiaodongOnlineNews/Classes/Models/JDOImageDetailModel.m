//
//  JDOImageDetailModel.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageDetailModel.h"

@implementation JDOImageDetailModel
- (id) initWithUrl:(NSString *) imageUrl andContent:(NSString *)imageContent {
    if(self = [super init]){
        self.imagecontent = imageContent;
        self.imageurl = imageUrl;
    }
    return self;
}
@end

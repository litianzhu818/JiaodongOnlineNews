//
//  JDOCommentModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    JDOReviewTypeNews = 0,
    JDOReviewTypeLivehood
}JDOReviewType;

@interface JDOCommentModel : NSObject

@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *uid;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *pubtime;
@property (nonatomic,copy) NSString *audit;

@end

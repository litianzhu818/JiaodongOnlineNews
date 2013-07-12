//
//  JDOQuestionDetailModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-11.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOQuestionDetailModel : NSObject

@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *department;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *question;
@property (nonatomic,strong) NSString *reply;
@property (nonatomic,strong) NSNumber *secret;
@property (nonatomic,strong) NSString *pwd;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *petname;
@property (nonatomic,strong) NSString *entry_date;
@property (nonatomic,strong) NSString *commentCount;
@property (nonatomic,strong) NSString *reply_date;
@property (nonatomic,strong) NSString *secondInfo;

@end

//
//  JDOQuestionModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOQuestionModel : NSObject

@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *department;
@property (nonatomic,strong) NSString *dept_code;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *entry_date;
@property (nonatomic,strong) NSString *info_type;
@property (nonatomic,strong) NSNumber *reply;
@property (nonatomic,strong) NSString *pubtime;

@end

//
//  JDONewsModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDONewsModel : NSObject <NSCoding>

@property (nonatomic,copy) NSString *atype;
@property (nonatomic,copy) NSString *clicknum;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *mpic;
@property (nonatomic,copy) NSString *pubtime;
@property (nonatomic,copy) NSString *summary;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *spic;
@property (nonatomic,copy) NSString *modifytime;

@end

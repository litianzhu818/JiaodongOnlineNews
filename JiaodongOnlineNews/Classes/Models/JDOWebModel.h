//
//  JDOWebModel.h
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-12-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDOToolbarModel.h"

@interface JDOWebModel : NSObject<JDOToolbarModel>
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *imageurl;
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *tinyurl;
-(id) initWithId:(NSString *)id andTitle:(NSString *)title andImageurl:(NSString *)imageurl andSummary:(NSString *)summary andTinyurl:(NSString *)tinyurl;
@end

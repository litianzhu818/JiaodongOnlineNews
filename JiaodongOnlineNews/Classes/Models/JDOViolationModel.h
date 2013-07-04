//
//  JDOViolationModel.h
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-1.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOViolationModel : NSObject

@property (nonatomic,copy) NSString *violationData;
@property (nonatomic,copy) NSString *violationLocation;
@property (nonatomic,copy) NSString *violationAction;
@property (nonatomic,copy) NSString *istreated;
@property (nonatomic,copy) NSString *ispaid;

@end

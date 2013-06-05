//
//  JDONewsModel.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LoadDataSuccessBlock)(NSArray *dataList);
typedef void(^LoadDataFailureBlock)(NSString *errorStr);

#define NewsHead_Page_Size 3
#define NewsList_Page_Size 20

@interface JDONewsModel : NSObject

@property (nonatomic,copy) NSString *atype;
@property (nonatomic,copy) NSString *clicknum;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *mpic;
@property (nonatomic,copy) NSString *pubtime;
@property (nonatomic,copy) NSString *summary;
@property (nonatomic,copy) NSString *title;

+ (void)loadNewsListChannel:(NSString *)channel pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;
+ (void)loadHeadlineChannel:(NSString *)channel pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

@end

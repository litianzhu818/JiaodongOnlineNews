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

@property (nonatomic,strong) NSString *atype;
@property (nonatomic,strong) NSString *clicknum;
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *mpic;
@property (nonatomic,strong) NSString *pubtime;
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *title;

+ (void)loadNewsListChannel:(NSString *)channel pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;
+ (void)loadHeadlineChannel:(NSString *)channel pageNum:(int)pageNum success:(LoadDataSuccessBlock)success failure:(LoadDataFailureBlock)failure;

@end

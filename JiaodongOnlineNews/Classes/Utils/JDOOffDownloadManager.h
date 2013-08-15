//
//  JDOOffDownloadManager.h
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-8-1.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDOOffDownloadManager : NSObject <SDWebImageManagerDelegate>
-(id) initWithTarget:(id)target action:(SEL)action;
-(void)cancelAll;
@end

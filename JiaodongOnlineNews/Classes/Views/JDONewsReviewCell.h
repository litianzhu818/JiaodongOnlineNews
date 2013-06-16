//
//  JDONewsReviewCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-9.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Comment_Name_Width  120
#define Comment_Name_Height 20
#define Comment_Time_Width  120

@class JDOCommentModel;

@interface JDONewsReviewCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setModel:(JDOCommentModel *)newsModel;

@end

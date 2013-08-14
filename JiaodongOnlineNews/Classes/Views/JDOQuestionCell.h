//
//  JDOQuestionCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Dept_Font_Size 14
#define Dept_Label_Height [UIFont systemFontOfSize:14].lineHeight
#define Code_Font_Size 14
#define Code_Label_Height [UIFont systemFontOfSize:14].lineHeight
#define Title_Font_Size 16
#define Cell_Padding 7.0f

@class JDOQuestionModel;

@interface JDOQuestionCell : UITableViewCell

@property (nonatomic)BOOL isMine;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setModel:(JDOQuestionModel *)questionModel;

@end

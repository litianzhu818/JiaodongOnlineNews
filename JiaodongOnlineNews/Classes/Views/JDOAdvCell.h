//
//  JDOAdvCell.h
//  JiaodongOnlineNews
//
//  Created by Roc on 14-5-5.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOAdvCell : UITableViewCell

@property (nonatomic,strong) NSArray *datas;
@property (nonatomic,assign) int currentPage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setDataArray:(NSArray *)dataArray;

@end

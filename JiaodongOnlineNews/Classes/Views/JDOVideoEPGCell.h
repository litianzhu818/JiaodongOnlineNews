//
//  JDOVideoEPGCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-5-21.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//
#import "JDOVideoEPGList.h"
#import "JDOVideoEPGModel.h"

@class JDOVideoEPGModel;

@interface JDOVideoEPGCell : UITableViewCell

@property (nonatomic,assign) JDOVideoEPGList *list;
@property (nonatomic,strong) JDOVideoEPGModel *epgModel;
@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,strong) UIImageView *background;

- (void)setModel:(JDOVideoEPGModel *)epgModel atIndexPath:(NSIndexPath *)indexPath;

@end

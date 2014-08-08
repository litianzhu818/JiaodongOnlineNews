//
//  JDOOnDemandEPGCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOOnDemandEPGList.h"
#import "JDOVideoOnDemandModel.h"

@interface JDOOnDemandEPGCell : UITableViewCell

@property (nonatomic,strong) JDOOnDemandEPGList *list;
@property (nonatomic,strong) JDOVideoOnDemandModel *epgModel;
@property (nonatomic,assign) int row;

@property (nonatomic,strong) UIImageView *background;
@property (nonatomic,strong) UIImageView *frameView;

- (void)setModel:(JDOVideoOnDemandModel *)epgModel atIndexPath:(NSIndexPath *)indexPath;

@end

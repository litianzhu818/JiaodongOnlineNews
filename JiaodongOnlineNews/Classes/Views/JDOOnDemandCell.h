//
//  JDOOnDemandCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

@interface JDOOnDemandCell : UITableViewCell

@property (nonatomic,strong) NSArray* models;

- (void)setContentAtIndex:(NSInteger) index;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier models:(NSArray *)models;

@end

//
//  JDOOnDemandChannelCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-16.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

@interface JDOOnDemandChannelCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *dayMap;
@property (nonatomic,strong) NSArray *dayKey;

- (void)setContentAtIndex:(NSInteger) index map:(NSDictionary *)dayMap key:(NSArray *)dayKey;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

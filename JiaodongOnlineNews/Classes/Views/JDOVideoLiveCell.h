//
//  JDOVideoLiveCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

@class JDOVideoModel;

@protocol JDOVideoLiveDelegate <NSObject>

@required
- (void) onLiveChannelClick:(JDOVideoModel *)model;

@end

@interface JDOVideoLiveCell : UITableViewCell

@property (nonatomic,strong) NSArray* models;
@property (nonatomic,assign) id<JDOVideoLiveDelegate> delegate;

- (void)setContentAtIndex:(NSInteger) index;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier models:(NSArray *)models;

@end

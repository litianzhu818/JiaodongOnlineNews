//
//  JDOAudioLiveCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-11.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

@class JDOVideoModel;

@interface JDOAudioLiveCell : UITableViewCell

@property (nonatomic,strong) JDOVideoModel* model;

- (void)setModel:(JDOVideoModel *)model;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

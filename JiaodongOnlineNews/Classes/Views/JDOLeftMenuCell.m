//
//  JDOLeftMenuCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-20.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLeftMenuCell.h"

#define icon_size 42.0f
#define padding 20.0f

@implementation JDOLeftMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:18];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float cellHeight = self.frame.size.height;
    self.imageView.frame = CGRectMake(padding,(cellHeight-icon_size)/2,icon_size,icon_size);
    
    CGRect frame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(1.5*padding+icon_size,CGRectGetMinY(frame),100,CGRectGetHeight(frame));
}

@end

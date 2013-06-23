//
//  JDORightMenuCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-21.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDORightMenuCell.h"

#define icon_size 42.0f
#define label_width 80.0f
#define padding 20.0f

@implementation JDORightMenuCell

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
    float cellWidth = self.frame.size.width;
    self.imageView.frame = CGRectMake(cellWidth-1.3*padding-label_width-icon_size,(cellHeight-icon_size)/2,icon_size,icon_size);
    
    CGRect frame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(cellWidth-padding-label_width,CGRectGetMinY(frame),label_width,CGRectGetHeight(frame));
}

@end

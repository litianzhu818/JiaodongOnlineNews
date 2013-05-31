//
//  JDONewsTableCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-31.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsTableCell.h"
#import "JDOCommonUtil.h"

@implementation JDONewsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(7,7,72,55);
    
    float limgW =  self.imageView.image.size.width;
    if(limgW > 0) {
        float cellWidth = self.frame.size.width;
        float labelWdith = cellWidth - 89 - 7;
        CGRect frame = self.textLabel.frame;
        self.textLabel.frame = CGRectMake(89,CGRectGetMinY(frame),labelWdith,CGRectGetHeight(frame));
        frame = self.detailTextLabel.frame;
        self.detailTextLabel.frame = CGRectMake(89,CGRectGetMinY(frame),labelWdith,CGRectGetHeight(frame));
        
    }
}

@end

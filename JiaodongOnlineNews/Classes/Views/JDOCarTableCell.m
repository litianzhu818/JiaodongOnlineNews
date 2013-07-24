//
//  JDOCarTableCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCarTableCell.h"

@implementation JDOCarTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        carNum = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
        [carNum setBackgroundColor:[UIColor clearColor]];
        checkBox = [[M13Checkbox alloc] initWithTitle:@"自动提醒" andHeight:24.0];
        carNumString = [[NSString alloc] init];
    }
    return self;
}

- (void)setData:(NSDictionary *)data
{
    UIFont *font = [UIFont systemFontOfSize:13.0];
    CGSize size = CGSizeMake(270, 480);
    CGSize labelsize = CGSizeMake(0, 0);
    
    [carNum setNumberOfLines:0];
    [carNum setLineBreakMode:UILineBreakModeWordWrap];
    [carNum setFont:font];
    labelsize = [carNumString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [carNum setFrame:CGRectMake(5, 5, labelsize.width, labelsize.height)];
    [carNum setText:carNumString];
    [self.contentView addSubview:carNum];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

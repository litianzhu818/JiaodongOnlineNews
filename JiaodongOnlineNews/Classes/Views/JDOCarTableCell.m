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
    UIFont *font = [UIFont systemFontOfSize:18.0];
    CGSize size = CGSizeMake(270, 480);
    CGSize labelsize = CGSizeMake(0, 0);
    
    carNumString = [data objectForKey:@"carnum"];
    
    [carNum setNumberOfLines:0];
    [carNum setLineBreakMode:UILineBreakModeWordWrap];
    [carNum setFont:font];
    labelsize = [carNumString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [carNum setFrame:CGRectMake(10, 7, labelsize.width, labelsize.height)];
    [carNum setText:carNumString];
    [self.contentView addSubview:carNum];
    
    checkBox.frame = CGRectMake(self.frame.size.width - 10 - checkBox.frame.size.width, 5, checkBox.frame.size.width, checkBox.frame.size.height);
    
    [self.contentView addSubview:checkBox];
    
    self.frame = CGRectMake(0, 0, 320, checkBox.frame.size.height + 10);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
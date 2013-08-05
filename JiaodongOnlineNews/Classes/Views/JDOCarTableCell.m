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
        checkBox = [[M13Checkbox alloc] initWithTitle:@"自动提醒" andHeight:20.0];
        carNumString = [[NSString alloc] init];
    }
    return self;
}

- (void)setData:(NSDictionary *)data
{
    UIFont *font = [UIFont systemFontOfSize:18.0];
    CGSize size = CGSizeMake(270, 480);
    CGSize labelsize = CGSizeMake(0, 0);
    
    carNumString = [data objectForKey:@"hphm"];
    
    [carNum setNumberOfLines:0];
    [carNum setLineBreakMode:UILineBreakModeWordWrap];
    [carNum setFont:font];
    [carNum setTextColor:[UIColor colorWithHex:Gray_Color_Type1]];
    labelsize = [carNumString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [carNum setFrame:CGRectMake(10, 7, labelsize.width, labelsize.height)];
    [carNum setText:carNumString];
    [self.contentView addSubview:carNum];
    
    checkBox.frame = CGRectMake(self.frame.size.width - 10 - checkBox.frame.size.width, 7.5, checkBox.frame.size.width, checkBox.frame.size.height);
    
    [self.contentView addSubview:checkBox];
    
    self.frame = CGRectMake(10, 0, 300, 35);
    [self setSeparator:nil];
}

- (void)setSeparator:(UIImage *)separator
{
    if (separator != nil) {
        UIImageView *imageseparator = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 1, 310, 1)];
        [imageseparator setImage:separator];
        [self.contentView addSubview:imageseparator];
    } else {
        UIImageView *imageseparator = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 1, 310, 1)];
        [imageseparator setImage:[UIImage imageNamed:@"vio_line2"]];
        [self.contentView addSubview:imageseparator];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

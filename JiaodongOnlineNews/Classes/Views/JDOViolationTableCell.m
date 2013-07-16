//
//  JDOViolationTableCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-15.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOViolationTableCell.h"

@implementation JDOViolationTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        location = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        action = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        istreated = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        ispaid = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    return self;
}

- (void)setData:(NSDictionary *)data
{
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGSize size = CGSizeMake(270, 480);
    CGSize labelsize = CGSizeMake(0, 0);
    
    NSMutableString *timeString = [[NSMutableString alloc] initWithString:@"时间："];
    [timeString appendString:[data objectForKey:@"violationDate"]];
    NSMutableString *locationString = [[NSMutableString alloc] initWithString:@"地点："];
    [locationString appendString:[data objectForKey:@"violationLocation"]];
    NSMutableString *actionString = [[NSMutableString alloc] initWithString:@"行为："];
    [actionString appendString:[data objectForKey:@"violationAction"]];
    NSMutableString *istreatedString = [[NSMutableString alloc] initWithString:@"是否处理："];
    [istreatedString appendString:[data objectForKey:@"istreated"]];
    NSMutableString *ispaidString = [[NSMutableString alloc] initWithString:@"是否付款："];
    [ispaidString appendString:[data objectForKey:@"ispaid"]];
    
    
    [time setNumberOfLines:0];
    [time setLineBreakMode:UILineBreakModeWordWrap];
    [time setFont:font];
    labelsize = [timeString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [time setFrame:CGRectMake(5, 5, labelsize.width, labelsize.height)];
    [time setText:timeString];
    [self.contentView addSubview:time];
    
    [location setNumberOfLines:0];
    [location setLineBreakMode:UILineBreakModeWordWrap];
    [location setFont:font];
    labelsize = [locationString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [location setFrame:CGRectMake(5, time.bottom + 5, labelsize.width, labelsize.height)];
    [location setText:locationString];
    [self.contentView addSubview:location];
    
    [action setNumberOfLines:0];
    [action setLineBreakMode:UILineBreakModeWordWrap];
    [action setFont:font];
    labelsize = [actionString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [action setFrame:CGRectMake(5, location.bottom + 5, labelsize.width, labelsize.height)];
    [action setText:actionString];
    [self.contentView addSubview:action];
    
    [istreated setNumberOfLines:0];
    [istreated setLineBreakMode:UILineBreakModeWordWrap];
    [istreated setFont:font];
    labelsize = [istreatedString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [istreated setFrame:CGRectMake(5, action.bottom + 5, labelsize.width, labelsize.height)];
    [istreated setText:istreatedString];
    [self.contentView addSubview:istreated];
    
    [ispaid setNumberOfLines:0];
    [ispaid setLineBreakMode:UILineBreakModeWordWrap];
    [ispaid setFont:font];
    labelsize = [ispaidString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [ispaid setFrame:CGRectMake(5, istreated.bottom + 5, labelsize.width, labelsize.height)];
    [ispaid setText:ispaidString];
    [self.contentView addSubview:ispaid];
    
    [self setFrame:CGRectMake(0, 0, 280, 5 + time.height + 5 + location.height + 5 + action.height + 5 + istreated.height + 5 + ispaid.height
                              + 5)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

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
        self.iphone5Style = 0.0;
        
        timelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [timelabel setBackgroundColor:[UIColor clearColor]];
        locationlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [locationlabel setBackgroundColor:[UIColor clearColor]];
        actionlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [actionlabel setBackgroundColor:[UIColor clearColor]];
        istreatedlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [istreatedlabel setBackgroundColor:[UIColor clearColor]];
        ispaidlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [ispaidlabel setBackgroundColor:[UIColor clearColor]];
        
        time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [time setBackgroundColor:[UIColor clearColor]];
        location = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [location setBackgroundColor:[UIColor clearColor]];
        action = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [action setBackgroundColor:[UIColor clearColor]];
        istreated = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [istreated setBackgroundColor:[UIColor clearColor]];
        ispaid = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [ispaid setBackgroundColor:[UIColor clearColor]];
    }
    [self setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vio_result_background"]]];
    return self;
}

- (void)setData:(NSDictionary *)data
{
    UIFont *font = [UIFont systemFontOfSize:15.0];
    CGSize size = CGSizeMake(240, 480);
    CGSize labelsize = CGSizeMake(0, 0);
    
    NSString *timeString = [data objectForKey:@"violationDate"];
    NSString *locationString = [data objectForKey:@"violationLocation"];
    NSString *actionString = [data objectForKey:@"violationAction"];
    NSString *istreatedString = [data objectForKey:@"istreated"];
    NSString *ispaidString = [data objectForKey:@"ispaid"];
    
    labelsize = [@"时  间：" sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [timelabel setText:@"时  间："];
    [timelabel setFont:font];
    [timelabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [timelabel setFrame:CGRectMake(5, 5, labelsize.width, labelsize.height)];
    [self.contentView addSubview:timelabel];
    [time setNumberOfLines:0];
    [time setLineBreakMode:UILineBreakModeWordWrap];
    [time setFont:font];
    labelsize = [timeString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [time setFrame:CGRectMake(timelabel.frame.size.width, 5, labelsize.width, labelsize.height)];
    [time setText:timeString];
    [time setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:time];
    
    labelsize = [@"地  点：" sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [locationlabel setText:@"地  点："];
    [locationlabel setFont:font];
    [locationlabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [locationlabel setFrame:CGRectMake(5, time.bottom + 4, labelsize.width, labelsize.height)];
    [self.contentView addSubview:locationlabel];
    [location setNumberOfLines:0];
    [location setLineBreakMode:UILineBreakModeWordWrap];
    [location setFont:font];
    labelsize = [locationString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [location setFrame:CGRectMake(locationlabel.frame.size.width, time.bottom + 4, labelsize.width, labelsize.height)];
    [location setText:locationString];
    [location setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:location];
    
    labelsize = [@"行  为：" sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [actionlabel setText:@"行  为："];
    [actionlabel setFont:font];
    [actionlabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [actionlabel setFrame:CGRectMake(5, location.bottom + 4, labelsize.width, labelsize.height)];
    [self.contentView addSubview:actionlabel];
    [action setNumberOfLines:0];
    [action setLineBreakMode:UILineBreakModeWordWrap];
    [action setFont:font];
    labelsize = [actionString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [action setFrame:CGRectMake(actionlabel.frame.size.width, location.bottom + 4, labelsize.width, labelsize.height)];
    [action setText:actionString];
    [action setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:action];
    
    labelsize = [@"处理结果：" sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [istreatedlabel setText:@"处理结果："];
    [istreatedlabel setFont:font];
    [istreatedlabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [istreatedlabel setFrame:CGRectMake(5, action.bottom + 4, labelsize.width, labelsize.height)];
    [self.contentView addSubview:istreatedlabel];
    [istreated setNumberOfLines:0];
    [istreated setLineBreakMode:UILineBreakModeWordWrap];
    [istreated setFont:font];
    labelsize = [istreatedString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [istreated setFrame:CGRectMake(istreatedlabel.frame.size.width, action.bottom + 4, labelsize.width, labelsize.height)];
    [istreated setText:istreatedString];
    [istreated setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:istreated];
    
    labelsize = [@"是否已交款：" sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [ispaidlabel setText:@"是否已交款："];
    [ispaidlabel setFont:font];
    [ispaidlabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [ispaidlabel setFrame:CGRectMake(5, istreated.bottom + 4, labelsize.width, labelsize.height)];
    [self.contentView addSubview:ispaidlabel];
    [ispaid setNumberOfLines:0];
    [ispaid setLineBreakMode:UILineBreakModeWordWrap];
    [ispaid setFont:font];
    labelsize = [ispaidString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    [ispaid setFrame:CGRectMake(ispaidlabel.frame.size.width, istreated.bottom + 4, labelsize.width, labelsize.height)];
    [ispaid setText:ispaidString];
    [ispaid setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:ispaid];
    
    [self setFrame:CGRectMake(0, 0, 294, 5 + time.height + 4 + location.height + 4 + action.height + 4 + istreated.height + 4 + ispaid.height
                              + 5 + self.iphone5Style)];
}

- (void)setIphone5Style
{
    
}

- (void)setSeparator:(UIImage *)separator
{
    if (separator != nil) {
        UIImageView *imageseparator = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 2.5, 294, 2.5)];
        [imageseparator setImage:separator];
        [self.contentView addSubview:imageseparator];
    } else {
        UIImageView *imageseparator = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, 294, 1)];
        [imageseparator setImage:[UIImage imageNamed:@"vio_line3"]];
        [self.contentView addSubview:imageseparator];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

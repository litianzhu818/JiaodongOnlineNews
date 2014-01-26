//
//  JDOViolationTableCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-15.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOShipTableCell.h"
#import "UIView+Common.h"

#define Image_Seperator_Tag 101

@implementation JDOShipTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.iphone5Style = 0.0;
        
        numlabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [numlabel setBackgroundColor:[UIColor clearColor]];
        linelabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [linelabel setBackgroundColor:[UIColor clearColor]];
        namelabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [namelabel setBackgroundColor:[UIColor clearColor]];
        begtimelabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [begtimelabel setBackgroundColor:[UIColor clearColor]];
        endtimelabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [endtimelabel setBackgroundColor:[UIColor clearColor]];
        terminallabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [terminallabel setBackgroundColor:[UIColor clearColor]];
        ticketlabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [ticketlabel setBackgroundColor:[UIColor clearColor]];
        
        num = [[UILabel alloc] initWithFrame:CGRectZero];
        [num setBackgroundColor:[UIColor clearColor]];
        line = [[UILabel alloc] initWithFrame:CGRectZero];
        [line setBackgroundColor:[UIColor clearColor]];
        name = [[UILabel alloc] initWithFrame:CGRectZero];
        [name setBackgroundColor:[UIColor clearColor]];
        begtime = [[UILabel alloc] initWithFrame:CGRectZero];
        [begtime setBackgroundColor:[UIColor clearColor]];
        endtime = [[UILabel alloc] initWithFrame:CGRectZero];
        [endtime setBackgroundColor:[UIColor clearColor]];
        terminal = [[UILabel alloc] initWithFrame:CGRectZero];
        [terminal setBackgroundColor:[UIColor clearColor]];
        ticket = [[UILabel alloc] initWithFrame:CGRectZero];
        [ticket setBackgroundColor:[UIColor clearColor]];
    }
    [self setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vio_result_background"]]];
    return self;
}

- (void)setData:(TFHppleElement *)data
{
    NSData *htmldata = [data.raw dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:htmldata encoding:@"UTF-8"];
    NSArray *array = [hpple searchWithXPathQuery:@"//td"];
    
    UIFont *font = [UIFont systemFontOfSize:15.0];
    CGSize labelsize;
    NSString *numString = [(TFHppleElement *)[array objectAtIndex:0] text];
    NSString *lineString = [(TFHppleElement *)[array objectAtIndex:1] text];
    NSString *nameString = [(TFHppleElement *)[array objectAtIndex:2] text];
    NSString *begtimeString = [(TFHppleElement *)[array objectAtIndex:3] text];
    NSString *endtimeString = [(TFHppleElement *)[array objectAtIndex:4] text];
    NSString *terminalString = [(TFHppleElement *)[array objectAtIndex:5] text];
    NSString *ticketString = [(TFHppleElement *)[array objectAtIndex:6] text];
    
    [numlabel setText:@"航  班："];
    [numlabel setFont:font];
    [numlabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [numlabel setFrame:CGRectMake(5, 5, 0, 0)];
    [numlabel sizeToFit];
    [self.contentView addSubview:numlabel];
    [num setNumberOfLines:0];
    [num setLineBreakMode:NSLineBreakByWordWrapping];
    [num setFont:font];
    labelsize = [numString sizeWithFont:font constrainedToSize:CGSizeMake(294-numlabel.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [num setFrame:CGRectMake(numlabel.frame.size.width, 5, labelsize.width, labelsize.height)];
    [num setText:numString];
    [num setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:num];
    
    [linelabel setText:@"航  线："];
    [linelabel setFont:font];
    [linelabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [linelabel setFrame:CGRectMake(5, num.bottom + 4, 0 , 0)];
    [linelabel sizeToFit];
    [self.contentView addSubview:linelabel];
    [line setNumberOfLines:0];
    [line setLineBreakMode:NSLineBreakByWordWrapping];
    [line setFont:font];
    labelsize = [lineString sizeWithFont:font constrainedToSize:CGSizeMake(294-linelabel.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [line setFrame:CGRectMake(linelabel.frame.size.width, num.bottom + 4, labelsize.width, labelsize.height)];
    [line setText:lineString];
    [line setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:line];
    
    [namelabel setText:@"船  名："];
    [namelabel setFont:font];
    [namelabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [namelabel setFrame:CGRectMake(5, line.bottom + 4, 0, 0)];
    [namelabel sizeToFit];
    [self.contentView addSubview:namelabel];
    [name setNumberOfLines:0];
    [name setLineBreakMode:NSLineBreakByWordWrapping];
    [name setFont:font];
    labelsize = [nameString sizeWithFont:font constrainedToSize:CGSizeMake(294-namelabel.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [name setFrame:CGRectMake(namelabel.frame.size.width, line.bottom + 4, labelsize.width, labelsize.height)];
    [name setText:nameString];
    [name setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:name];
    
    [begtimelabel setText:@"开航时间："];
    [begtimelabel setFont:font];
    [begtimelabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [begtimelabel setFrame:CGRectMake(5, name.bottom + 4, 0, 0)];
    [begtimelabel sizeToFit];
    [self.contentView addSubview:begtimelabel];
    [begtime setNumberOfLines:0];
    [begtime setLineBreakMode:NSLineBreakByWordWrapping];
    [begtime setFont:font];
    labelsize = [begtimeString sizeWithFont:font constrainedToSize:CGSizeMake(294-begtimelabel.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [begtime setFrame:CGRectMake(begtimelabel.frame.size.width, name.bottom + 4, labelsize.width, labelsize.height)];
    [begtime setText:begtimeString];
    [begtime setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:begtime];
    
    [endtimelabel setText:@"到港时间："];
    [endtimelabel setFont:font];
    [endtimelabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [endtimelabel setFrame:CGRectMake(5, begtime.bottom + 4, 0, 0)];
    [endtimelabel sizeToFit];
    [self.contentView addSubview:endtimelabel];
    [endtime setNumberOfLines:0];
    [endtime setLineBreakMode:NSLineBreakByWordWrapping];
    [endtime setFont:font];
    labelsize = [endtimeString sizeWithFont:font constrainedToSize:CGSizeMake(294-endtimelabel.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [endtime setFrame:CGRectMake(endtimelabel.frame.size.width, begtime.bottom + 4, labelsize.width, labelsize.height)];
    [endtime setText:endtimeString];
    [endtime setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:endtime];
    
    [terminallabel setText:@"靠泊地点："];
    [terminallabel setFont:font];
    [terminallabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [terminallabel setFrame:CGRectMake(5, endtime.bottom + 4, 0, 0)];
    [terminallabel sizeToFit];
    [self.contentView addSubview:terminallabel];
    [terminal setNumberOfLines:0];
    [terminal setLineBreakMode:NSLineBreakByWordWrapping];
    [terminal setFont:font];
    labelsize = [terminalString sizeWithFont:font constrainedToSize:CGSizeMake(294-terminallabel.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [terminal setFrame:CGRectMake(terminallabel.frame.size.width, endtime.bottom + 4, labelsize.width, labelsize.height)];
    [terminal setText:terminalString];
    [terminal setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:terminal];
    
    [ticketlabel setText:@"售票状态："];
    [ticketlabel setFont:font];
    [ticketlabel setTextColor:[UIColor colorWithHex:@"96826e"]];
    [ticketlabel setFrame:CGRectMake(5, terminal.bottom + 4, 0, 0)];
    [ticketlabel sizeToFit];
    [self.contentView addSubview:ticketlabel];
    [ticket setNumberOfLines:0];
    [ticket setLineBreakMode:NSLineBreakByWordWrapping];
    [ticket setFont:font];
    labelsize = [ticketString sizeWithFont:font constrainedToSize:CGSizeMake(294-ticketlabel.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    [ticket setFrame:CGRectMake(ticketlabel.frame.size.width, terminal.bottom + 4, labelsize.width, labelsize.height)];
    [ticket setText:endtimeString];
    [ticket setTextColor:[UIColor colorWithHex:@"5a463c"]];
    [self.contentView addSubview:ticket];
    
    [self setFrame:CGRectMake(0, 0, 294, 5 + numlabel.height + 4 + linelabel.height + 4 + namelabel.height + 4 + begtimelabel.height + 4 + endtimelabel.height + 4 + terminallabel.height + 4 + ticketlabel.height + 5 + self.iphone5Style)];
}

- (void)setSeparator:(UIImage *)separator
{
    [[self viewWithTag:Image_Seperator_Tag] removeFromSuperview];
    if (separator != nil) {
        UIImageView *imageseparator = [[UIImageView alloc] initWithFrame:CGRectMake(0.5, self.frame.size.height - 2.5, 293, 2.5)];
        imageseparator.tag = Image_Seperator_Tag;
        [imageseparator setImage:separator];
        [self.contentView addSubview:imageseparator];
    } else {
        UIImageView *imageseparator = [[UIImageView alloc] initWithFrame:CGRectMake(0.5, self.frame.size.height - 1, 293, 1)];
        imageseparator.tag = Image_Seperator_Tag;
        [imageseparator setImage:[UIImage imageNamed:@"vio_line3"]];
        [self.contentView addSubview:imageseparator];
    }
}


@end

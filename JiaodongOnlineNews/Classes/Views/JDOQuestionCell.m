//
//  JDOQuestionCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOQuestionCell.h"
#import "JDOQuestionModel.h"
#import "NIFoundationMethods.h"
#import "SSLineView.h"

#define Dept_Label_Width  300
#define Code_Label_Width  150
#define Reply_Font_Size 14
#define Reply_Label_Width  100

@interface JDOQuestionCell ()

@property (nonatomic,strong) UILabel *codeLabel;
@property (nonatomic,strong) UILabel *replyLabel;
@property (nonatomic,strong) SSLineView *separatorLine;

@end

@implementation JDOQuestionCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont systemFontOfSize:Dept_Font_Size];
        self.textLabel.textColor = [UIColor colorWithHex:@"1673ba"];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:Title_Font_Size];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.detailTextLabel.textColor = [UIColor colorWithHex:@"505050"];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.codeLabel.font = [UIFont systemFontOfSize:Code_Font_Size];
        self.codeLabel.textColor = [UIColor colorWithHex:@"969696"];
        self.codeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.codeLabel];
        
        self.replyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.replyLabel.font = [UIFont systemFontOfSize:Reply_Font_Size];
        self.replyLabel.textColor = [UIColor colorWithHex:@"969696"];
        self.replyLabel.textAlignment = UITextAlignmentRight;
        self.replyLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.replyLabel];
        
        self.separatorLine = [[SSLineView alloc] initWithFrame:CGRectZero];
        self.separatorLine.lineColor = [UIColor colorWithHex:@"d3d3d3"];
        self.separatorLine.insetColor = [UIColor colorWithHex:@"f0f0f0"];
        [self.contentView addSubview:self.separatorLine];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.textLabel.frame = CGRectMake(10, 10, Dept_Label_Width, Dept_Label_Height);
    float titieHeight = NISizeOfStringWithLabelProperties(self.detailTextLabel.text, CGSizeMake(300, MAXFLOAT), [UIFont systemFontOfSize:Title_Font_Size], UILineBreakModeWordWrap, 0).height;
    self.detailTextLabel.frame = CGRectMake(10, 10+Dept_Label_Height+Cell_Padding, 300, titieHeight);
    
    self.codeLabel.frame = CGRectMake(10, CGRectGetMaxY(self.detailTextLabel.frame)+Cell_Padding, Code_Label_Width, Code_Label_Height);
    self.replyLabel.frame = CGRectMake(320-10-Reply_Label_Width, CGRectGetMaxY(self.detailTextLabel.frame)+Cell_Padding, Reply_Label_Width, Code_Label_Height);
    
    self.separatorLine.frame = CGRectMake(10, CGRectGetMaxY(self.codeLabel.frame)+Cell_Padding, 320-20, 1);
}

- (void)setModel:(JDOQuestionModel *)questionModel{
    if(questionModel == nil){
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.text = @"暂无相关问题";
        self.detailTextLabel.text = nil;
        self.codeLabel.text = nil;
        self.replyLabel.text = nil;
        self.separatorLine.hidden = true;
    }else{
        self.textLabel.textColor = [UIColor colorWithHex:@"1673ba"];
        self.textLabel.text = [NSString stringWithFormat:@"处理部门:%@", questionModel.department];
        self.detailTextLabel.text = questionModel.title;
        self.codeLabel.text = [NSString stringWithFormat:@"编号:[%@]",questionModel.id];
        if([(NSNumber *)questionModel.reply boolValue]){
            self.replyLabel.text = @"已回复";
            self.replyLabel.textColor = [UIColor colorWithHex:@"dd141c"];
        }else{
            self.replyLabel.text = @"未回复";
            self.replyLabel.textColor = [UIColor colorWithHex:@"969696"];
        }
        
        self.separatorLine.hidden = false;
    }
}

@end
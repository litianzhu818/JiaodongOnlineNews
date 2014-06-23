//
//  JDONewsReviewCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-9.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsReviewCell.h"
#import "JDOCommentModel.h"
#import "NIFoundationMethods.h"
#import "JDOQuestionCommentModel.h"

@interface JDONewsReviewCell ()

@property (nonatomic,strong) UILabel *pubtimeLabel;
@property (nonatomic,strong) UIImageView *separatorLine;

@end

@implementation JDONewsReviewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont systemFontOfSize:Review_Font_Size];
        self.textLabel.backgroundColor = [UIColor clearColor];
//        self.textLabel.layer.borderWidth = 2;
//        self.textLabel.layer.borderColor = [UIColor redColor].CGColor;
//        self.detailTextLabel.layer.borderWidth = 2;
//        self.detailTextLabel.layer.borderColor = [UIColor redColor].CGColor;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:Review_Font_Size];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.detailTextLabel.textColor = [UIColor colorWithHex:Black_Color_Type2];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.pubtimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-Comment_Time_Width-10, 10, Comment_Time_Width, Comment_Name_Height)];
        self.pubtimeLabel.font = [UIFont systemFontOfSize:Review_Font_Size];
        self.pubtimeLabel.textColor = [UIColor colorWithHex:Gray_Color_Type2];
        self.pubtimeLabel.textAlignment = UITextAlignmentRight;
        self.pubtimeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.pubtimeLabel];
        
        self.separatorLine = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.separatorLine.image = [UIImage imageNamed:@"full_separator_line"];
        [self.contentView addSubview:self.separatorLine];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(10, 10, Comment_Name_Width, Comment_Name_Height);
    float contentHeight = NISizeOfStringWithLabelProperties(self.detailTextLabel.text, CGSizeMake(300, MAXFLOAT), [UIFont systemFontOfSize:Review_Font_Size], UILineBreakModeWordWrap, 0).height;
    self.detailTextLabel.frame = CGRectMake(10, 10+Comment_Name_Height+5, 300, contentHeight);
    self.separatorLine.frame = CGRectMake(10, 10+Comment_Name_Height+5+contentHeight+10, 320-20, 1);
}

- (void)setNewsModel:(JDOCommentModel *)commentModel{
    if(commentModel == nil){
        self.textLabel.text = nil;
        self.detailTextLabel.text = nil;
        self.pubtimeLabel.text = nil;
        self.separatorLine.hidden = true;
    }else{
        self.textLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
        self.textLabel.text = JDOIsEmptyString(commentModel.nickName) ? @"胶东在线网友" :commentModel.nickName;
        self.detailTextLabel.text = commentModel.content;
        self.pubtimeLabel.text = [commentModel.pubtime substringWithRange:NSMakeRange(5,11)]; //mm-dd hh:mi
        self.separatorLine.hidden = false;
    }
}

- (void)setQuestionModel:(JDOQuestionCommentModel *)commentModel{
    if(commentModel == nil){
        self.textLabel.text = nil;
        self.detailTextLabel.text = nil;
        self.pubtimeLabel.text = nil;
        self.separatorLine.hidden = true;
    }else{
        self.textLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
        self.textLabel.text = JDOIsEmptyString(commentModel.username) ? @"胶东在线网友" :commentModel.username;
        self.detailTextLabel.text = commentModel.liuyan;
        self.pubtimeLabel.text = [commentModel.pubtime substringWithRange:NSMakeRange(5,11)]; //mm-dd hh:mi
        self.separatorLine.hidden = false;
    }
}

@end

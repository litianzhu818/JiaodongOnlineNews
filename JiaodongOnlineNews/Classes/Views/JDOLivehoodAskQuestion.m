//
//  JDOLivehoodAskQuestion.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodAskQuestion.h"
#import "InsetsTextField.h"
#import "TPKeyboardAvoidingScrollView.h"

#define Line_Height 28.0f
#define Label_Wdith 100.0f
#define Input_Wdith 210.0f

@interface JDOLivehoodAskQuestion ()

@property (strong,nonatomic) TPKeyboardAvoidingScrollView *mainView;
@property (nonatomic,strong) InsetsTextField *userInput;
@property (nonatomic,strong) InsetsTextField *telInput;
@property (nonatomic,strong) UITextView *contentInput;

@end

@implementation JDOLivehoodAskQuestion

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info {
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        
        self.reuseIdentifier = [info valueForKey:@"reuseId"];
        
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
        
        _mainView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.bounds];
        _mainView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        [self addSubview:_mainView];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Label_Wdith, Line_Height)];
        userLabel.backgroundColor = [UIColor clearColor];
        userLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
        userLabel.font = [UIFont systemFontOfSize:16];
        userLabel.text = @"用户昵称:";
        [self.mainView addSubview:userLabel];
        
        _userInput = [[InsetsTextField alloc] initWithFrame:CGRectMake(Label_Wdith+20, 10, Input_Wdith, Line_Height)];
        _userInput.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        [self.mainView addSubview:_userInput];
        
        UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(userLabel.frame)+10, Label_Wdith, Line_Height)];
        telLabel.backgroundColor = [UIColor clearColor];
        telLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
        telLabel.text = @"联系电话:";
        [self.mainView addSubview:telLabel];
        
        _telInput = [[InsetsTextField alloc] initWithFrame:CGRectMake(Label_Wdith+20, CGRectGetMaxY(userLabel.frame)+10, Input_Wdith, Line_Height)];
        _telInput.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        _telInput.keyboardType = UIKeyboardTypePhonePad;
        [self.mainView addSubview:_telInput];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(telLabel.frame)+10, Label_Wdith, Line_Height)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
        contentLabel.text = @"留言内容:";
        [self.mainView addSubview:contentLabel];
        
        _contentInput = [[UITextView alloc] initWithFrame:CGRectMake(Label_Wdith+20, CGRectGetMaxY(telLabel.frame)+10, Input_Wdith, 100)];
        _contentInput.backgroundColor = [UIColor clearColor];
        _contentInput.font = [UIFont systemFontOfSize:16];
        //    _contentInput.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
        UIImageView *contentInputMask = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
        contentInputMask.frame = _contentInput.frame;
        [self.mainView addSubview:contentInputMask];
        [self.mainView addSubview:_contentInput];
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:[UIImage imageNamed:@"livehood_continue_button"] forState:UIControlStateNormal];
        [submitBtn setTitle:@"提交留言" forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
        submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        submitBtn.frame = CGRectMake(10, CGRectGetMaxY(_contentInput.frame)+10, 300, 43);
        [self.mainView addSubview:submitBtn];
        
    }
    return self;
}

- (void) addLabel:(NSString *)text frame:(CGRect) frame{
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Label_Wdith, Line_Height)];
    userLabel.backgroundColor = [UIColor clearColor];
    userLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
    userLabel.font = [UIFont systemFontOfSize:16];
    userLabel.text = @"用户昵称:";
    [self.mainView addSubview:userLabel];
}


@end

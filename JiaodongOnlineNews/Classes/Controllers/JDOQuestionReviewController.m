//
//  JDOQuestionReviewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-15.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOQuestionReviewController.h"
#import "JDOQuestionModel.h"
#import "InsetsTextField.h"

#define Line_Height 35.0f
#define Label_Wdith 80.0f
#define Input_Wdith 210.0f

@interface JDOQuestionReviewController ()

@property (nonatomic,strong) InsetsTextField *userInput;
@property (nonatomic,strong) InsetsTextField *telInput;
@property (nonatomic,strong) UITextView *contentInput;

@end

@implementation JDOQuestionReviewController

- (id)initWithQuestionModel:(JDOQuestionModel *)questionModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.questionModel = questionModel;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // 内容
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
    
    _mainView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
    _mainView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    [self.view addSubview:_mainView];
    
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, Label_Wdith, Line_Height)];
    userLabel.backgroundColor = [UIColor clearColor];
    userLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
    userLabel.font = [UIFont systemFontOfSize:16];
    userLabel.text = @"用户昵称";
    [self.mainView addSubview:userLabel];
    
    _userInput = [[InsetsTextField alloc] initWithFrame:CGRectMake(Label_Wdith+20, 10, Input_Wdith, Line_Height)];
    _userInput.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    _userInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _userInput.font = [UIFont systemFontOfSize:16];
    [self.mainView addSubview:_userInput];
    
    UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(userLabel.frame)+10, Label_Wdith, Line_Height)];
    telLabel.backgroundColor = [UIColor clearColor];
    telLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
    telLabel.font = [UIFont systemFontOfSize:16];
    telLabel.text = @"联系电话";
    [self.mainView addSubview:telLabel];
    
    _telInput = [[InsetsTextField alloc] initWithFrame:CGRectMake(Label_Wdith+20, CGRectGetMaxY(userLabel.frame)+10, Input_Wdith, Line_Height)];
    _telInput.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    _telInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _telInput.keyboardType = UIKeyboardTypePhonePad;
    _telInput.font = [UIFont systemFontOfSize:16];
    [self.mainView addSubview:_telInput];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(telLabel.frame)+10, Label_Wdith, Line_Height)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.text = @"留言内容";
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

-(void)viewDidUnload{
    [super viewDidUnload];
}

#pragma mark - Navigation

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToQuestionDetail)];
    [self.navigationView setTitle:@"问题评论"];
}

- (void) backToQuestionDetail{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

- (void)submitReview{
    
    if(JDOIsEmptyString(_userInput.text)){
        [JDOCommonUtil showHintHUD:@"请输入用户昵称" inView:self.view];
        return;
    }
    if(JDOIsEmptyString(_contentInput.text)){
        [JDOCommonUtil showHintHUD:@"请输入留言内容" inView:self.view];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setObject:self.questionModel.id forKey:@"qid"];
    [params setObject:self.questionModel.dept_code forKey:@"dept_code"];
    [params setObject:[_userInput.text stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] forKey:@"username"];
    if(!JDOIsEmptyString(_telInput.text)){
        [params setObject:[_telInput.text stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] forKey:@"contact"];
    }
    [params setObject:[_contentInput.text stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] forKey:@"content"];
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_ADD_COMMENT_SERVICE modelClass:nil params:params success:^(NSDictionary *result) {
        id resultStatus = [result objectForKey:@"status"];
        if([resultStatus isKindOfClass:[NSNumber class]]){
            NSNumber *status = (NSNumber *)resultStatus;
            if([status intValue] == 1 ){ // 1:提交成功 0:提交失败
                _userInput.text = nil;
                _telInput.text = nil;
                _contentInput.text = nil;
                [self backToQuestionDetail];
            }else if([status intValue] == 0){
                NSLog(@"提交失败,服务器错误");
                [JDOCommonUtil showHintHUD:@"服务器错误" inView:self.view];
            }
        }else if([resultStatus isKindOfClass:[NSString class]]){
            NSString *error = (NSString *)resultStatus;
            if ([error isEqualToString:@"wrongparam"]){
                [JDOCommonUtil showHintHUD:@"参数错误" inView:self.view];
            }else if ([error isEqualToString:@"wrongdept"]){
                [JDOCommonUtil showHintHUD:@"代码错误" inView:self.view];
            }
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
    }];

}


@end

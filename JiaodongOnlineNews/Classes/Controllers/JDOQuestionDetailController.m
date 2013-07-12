//
//  JDOLivehoodDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-11.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOQuestionDetailController.h"
#import "JDOQuestionModel.h"
#import "JDOToolBar.h"
#import "JDOReviewListController.h"
#import "UIDevice+IdentifierAddition.h"
#import "JDOQuestionDetailModel.h"
#import "FXLabel.h"

#define Dept_Label_Tag 101
#define Title_Label_Tag 102
#define Subtitle_Label_Tag 103


@interface JDOQuestionDetailController ()

@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;

@end

@implementation JDOQuestionDetailController

- (id)initWithQuestionModel:(JDOQuestionModel *)questionModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.questionModel = questionModel;
    }
    return self;
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.mainView.hidden = false;
        self.toolbar.hidden = false;
    }else{
        self.mainView.hidden = true;
        self.toolbar.hidden = true;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // 内容
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44-44)];
    _mainView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
    [self.view addSubview:_mainView];
    
    // 工具栏输入框
    NSArray *toolbarBtnConfig = @[[NSNumber numberWithInt:ToolBarInputField]];
    NSArray *toolbarWidthConfig = @[
        @{@"frameWidth":[NSNumber numberWithFloat:1],@"controlWidth":[NSNumber numberWithFloat:1],@"controlHeight":[NSNumber numberWithFloat:1]}
    ];
    
    _toolbar = [[JDOToolBar alloc] initWithModel:self.questionModel parentView:self.view typeConfig:toolbarBtnConfig widthConfig:nil frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];// 背景有透明渐变,高度是56不是44
    [self.view addSubview:_toolbar];
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
    self.statusView.delegate = self;
    [self.view addSubview:self.statusView];
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.toolbar action:@selector(hideReviewView)];
    _blackMask = self.view.blackMask;
    [_blackMask addGestureRecognizer:self.closeReviewGesture];
    
    [self loadDataFromNetwork];
    
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [self setToolbar:nil];
    
    [_blackMask removeGestureRecognizer:self.closeReviewGesture];
}

#pragma mark - Navigation

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToViewList)];
    [self.navigationView setTitle:@"问题详情"];
    [self.navigationView addRightButtonImage:@"top_navigation_review" highlightImage:@"top_navigation_review" target:self action:@selector(showReviewList)];
}

- (void) backToViewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

- (void) showReviewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithParams:@{@"aid":self.questionModel.id,@"deviceId":[[UIDevice currentDevice] uniqueDeviceIdentifier]}];
    [centerViewController pushViewController:reviewController animated:true];
}

- (void)loadDataFromNetwork{
    [self setCurrentState:ViewStatusLoading];
    // 返回的数据结构最外层是{data,status,info}，data中才是需要的内容
    [[JDOJsonClient sharedClient] getJSONByServiceName:QUESTION_DETAIL_SERVICE modelClass:nil params:@{@"info_id":self.questionModel.id} success:^(NSDictionary *dict) {
        if(dict != nil && [(NSNumber *)[dict objectForKey:@"status"] intValue] ==1 && [dict objectForKey:@"data"]!=nil){
            JDOQuestionDetailModel *model = [(NSDictionary *)[dict objectForKey:@"data"] jsonDictionaryToModel:[JDOQuestionDetailModel class]];
            [self dataLoadFinished:model];
            [self setCurrentState:ViewStatusNormal];
        }else{
            // 服务器端有错误
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (void) dataLoadFinished:(JDOQuestionDetailModel *)detailModel{
    UILabel *deptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 320-20, 0)];
    deptLabel.font = [UIFont systemFontOfSize:14];
    deptLabel.text = [NSString stringWithFormat:@"部门:%@",detailModel.department];
    deptLabel.textColor = [UIColor colorWithHex:@"1673ba"];
    deptLabel.backgroundColor = [UIColor clearColor];
    [deptLabel sizeToFit];
    [_mainView addSubview:deptLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(deptLabel.frame)+15, 320-20, [UIFont systemFontOfSize:18].lineHeight)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = detailModel.title;
    titleLabel.textColor = [UIColor colorWithHex:@"505050"];
    titleLabel.backgroundColor = [UIColor clearColor];
    float infactHeight = [detailModel.title sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail].height;
    if (infactHeight>titleLabel.frame.size.height) {
        [titleLabel sizeToFit];
    }
    [_mainView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+10, 320-20, [UIFont systemFontOfSize:14].lineHeight)];
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.text = [NSString stringWithFormat:@"%@  发表人:%@",detailModel.entry_date,JDOIsEmptyString(detailModel.petname)?detailModel.username:detailModel.petname];
    subtitleLabel.textColor = [UIColor colorWithHex:@"969696"];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    [_mainView addSubview:subtitleLabel];
    
    FXLabel *contentLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(subtitleLabel.frame)+15, 320-20, 0)];
    contentLabel.lineSpacing = 0.2;
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;// 必须用CharWrapping,否则只有一行,默认英文是按空格分割的
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.numberOfLines = 0;
    contentLabel.text = [detailModel.question stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    contentLabel.textColor = [UIColor colorWithHex:@"505050"];
    contentLabel.backgroundColor = [UIColor clearColor];
    [contentLabel sizeToFit];
    [_mainView addSubview:contentLabel];
    
    if(JDOIsEmptyString(detailModel.reply)){
        return;
    }
    // 有回复的情况下
    UIImageView *separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(contentLabel.frame)+15, 320-20, 1)];
    separatorLine.image = [UIImage imageNamed:@"full_separator_line"];
    [_mainView addSubview:separatorLine];
    
    UILabel *replyDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(separatorLine.frame)+15, 320-20, 0)];
    replyDateLabel.font = [UIFont systemFontOfSize:14];
    replyDateLabel.text = [NSString stringWithFormat:@"回复时间:%@",detailModel.reply_date];
    replyDateLabel.textColor = [UIColor colorWithHex:@"969696"];
    replyDateLabel.backgroundColor = [UIColor clearColor];
    [replyDateLabel sizeToFit];
    [_mainView addSubview:replyDateLabel];
    
    FXLabel *replyLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(replyDateLabel.frame)+10, 320-20, 0)];
    replyLabel.lineSpacing = 0.2;
    replyLabel.lineBreakMode = NSLineBreakByCharWrapping;
    replyLabel.font = [UIFont systemFontOfSize:14];
    replyLabel.numberOfLines = 0;
    replyLabel.text = [detailModel.reply stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    replyLabel.textColor = [UIColor colorWithHex:@"505050"];
    replyLabel.backgroundColor = [UIColor clearColor];
    [replyLabel sizeToFit];
    [_mainView addSubview:replyLabel];
    
    [_mainView setContentSize:CGSizeMake(320, CGRectGetMaxY(replyLabel.frame)+10)];
    
}

@end

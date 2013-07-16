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
#import "JDODataModel.h"
#import "DCParserConfiguration.h"
#import "DCCustomParser.h"
#import "DCKeyValueObjectMapping.h"
#import "JDOQuestionDetailModel.h"

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
    NSArray *toolbarBtnConfig = @[[NSNumber numberWithInt:ToolBarButtonReview],[NSNumber numberWithInt:ToolBarButtonCollect]];
    
    _toolbar = [[JDOToolBar alloc] initWithModel:self.questionModel parentController:self typeConfig:toolbarBtnConfig widthConfig:nil frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];// 背景有透明渐变,高度是56不是44
    _toolbar.reviewType = JDOReviewTypeLivehood;
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
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithType:JDOReviewTypeLivehood params:@{@"qid":self.questionModel.id}];
    [centerViewController pushViewController:reviewController animated:true];
}

- (void)loadDataFromNetwork{
    [self setCurrentState:ViewStatusLoading];
    // 返回的数据结构最外层是{data,status,info}，data中才是需要的内容
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCCustomParser *customParser = [[DCCustomParser alloc] initWithBlockParser:^id(NSDictionary *dictionary, NSString *attributeName, __unsafe_unretained Class destinationClass, id value) {
        DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOQuestionDetailModel class]];
        return [mapper parseDictionary:value];
    } forAttributeName:@"_data" onDestinationClass:[JDODataModel class]];
    [config addCustomParsersObject:customParser];
    
    [[JDOJsonClient sharedClient] getJSONByServiceName:QUESTION_DETAIL_SERVICE modelClass:@"JDODataModel" config:config params:@{@"info_id":self.questionModel.id} success:^(JDODataModel *dataModel) {
        if(dataModel != nil && [dataModel.status intValue] ==1 && dataModel.data != nil){
            JDOQuestionDetailModel *data = (JDOQuestionDetailModel *)dataModel.data;
            self.questionModel.dept_code = data.dept_code ;  // 提交评论时用到dept_code
            [self dataLoadFinished: data];
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
    
    NSMutableArray *content = [NSMutableArray array];
    [content addObject:[NSString stringWithFormat:@"部门：%@",detailModel.department]];
    [content addObject:detailModel.title];
    [content addObject:[NSString stringWithFormat:@"%@  发表人：%@",detailModel.entry_date,JDOIsEmptyString(detailModel.petname)?detailModel.username:detailModel.petname]];
    [content addObject:[[detailModel.question stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"] stringByTrimmingLeadingAndTrailingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    if (!JDOIsEmptyString(detailModel.reply)){
        [content addObject:[NSString stringWithFormat:@"回复时间：%@",detailModel.reply_date]];
        [content addObject:[[detailModel.reply stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"] stringByTrimmingLeadingAndTrailingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    }
    CGFloat totalHeight = [self buildContent:content startY:10];

    if(detailModel.secondInfo != nil){   // 有二次提问的情况下
        UIImageView *separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, totalHeight+15, 320-20, 1)];
        separatorLine.image = [UIImage imageNamed:@"full_separator_line"];
        [_mainView addSubview:separatorLine];

        NSMutableArray *content2 = [NSMutableArray array];
        [content2 addObject:@"追加提问"];
        [content2 addObject:@""];
        [content2 addObject:[NSString stringWithFormat:@"%@  发表人：%@",detailModel.secondInfo.entry_date,JDOIsEmptyString(detailModel.secondInfo.petname)?detailModel.secondInfo.username:detailModel.secondInfo.petname]];
        [content2 addObject:[[detailModel.secondInfo.question stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"] stringByTrimmingLeadingAndTrailingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        if (!JDOIsEmptyString(detailModel.secondInfo.reply)){
            [content2 addObject:[NSString stringWithFormat:@"回复时间：%@",detailModel.secondInfo.reply_date]];
            [content2 addObject:[[detailModel.secondInfo.reply stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"] stringByTrimmingLeadingAndTrailingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        }
        totalHeight = [self buildContent:content2 startY:totalHeight+25];
    }else{  // 没有二次提问则允许追问
        if(!JDOIsEmptyString(detailModel.reply)){
            UIButton *continueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [continueBtn setBackgroundImage:[UIImage imageNamed:@"livehood_continue_button"] forState:UIControlStateNormal];
            [continueBtn setTitle:@"追加提问" forState:UIControlStateNormal];
            [continueBtn addTarget:self action:@selector(continueAsk) forControlEvents:UIControlEventTouchUpInside];
            continueBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            continueBtn.frame = CGRectMake(10, totalHeight+15, 297, 43);
            [_mainView addSubview:continueBtn];
            totalHeight += 15+43;
        }
    }
    
    [_mainView setContentSize:CGSizeMake(320, totalHeight+15)];
    
}

- (void) continueAsk {
//    self.questionModel.id
}

- (CGFloat) buildContent:(NSArray *)content startY:(CGFloat)startY {
    UILabel *deptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startY, 320-20, 0)];
    deptLabel.font = [UIFont systemFontOfSize:14];
    deptLabel.text = [content objectAtIndex:0];
    deptLabel.textColor = [UIColor colorWithHex:@"1673ba"];
    deptLabel.backgroundColor = [UIColor clearColor];
    [deptLabel sizeToFit];
    [_mainView addSubview:deptLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(deptLabel.frame)+15, 320-20, [UIFont systemFontOfSize:18].lineHeight)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [content objectAtIndex:1];
    titleLabel.textColor = [UIColor colorWithHex:@"505050"];
    titleLabel.backgroundColor = [UIColor clearColor];
    // 内容小于一行的情况下直接调用sizeToFit会导致居中对齐无效
    float infactHeight = [titleLabel.text sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:NSLineBreakByTruncatingTail].height;
    if (infactHeight>titleLabel.frame.size.height) {
        [titleLabel sizeToFit];
    }
    [_mainView addSubview:titleLabel];
    if([titleLabel.text isEqualToString:@""]){  // 追加提问时不需要再显示标题
        titleLabel.frame = CGRectMake(10, CGRectGetMaxY(deptLabel.frame), 320-20, 0);
    }
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame)+10, 320-20, [UIFont systemFontOfSize:14].lineHeight)];
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.text = [content objectAtIndex:2];
    subtitleLabel.textColor = [UIColor colorWithHex:@"969696"];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    [_mainView addSubview:subtitleLabel];
    
    FXLabel *contentLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(subtitleLabel.frame)+15, 320-20, 0)];
    contentLabel.lineSpacing = 0.2;
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;// 必须用CharWrapping,否则只有一行,默认英文是按空格分割的
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.numberOfLines = 0;
    contentLabel.text = [content objectAtIndex:3];
    contentLabel.textColor = [UIColor colorWithHex:@"505050"];
    contentLabel.backgroundColor = [UIColor clearColor];
    [contentLabel sizeToFit];
    [_mainView addSubview:contentLabel];
    
    if( content.count == 4){
        return CGRectGetMaxY(contentLabel.frame);
    }
    // 有回复的情况下
    UIImageView *separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(contentLabel.frame)+15, 320-20, 1)];
    separatorLine.image = [UIImage imageNamed:@"full_separator_line"];
    [_mainView addSubview:separatorLine];
    
    UILabel *replyDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(separatorLine.frame)+15, 320-20, 0)];
    replyDateLabel.font = [UIFont systemFontOfSize:14];
    replyDateLabel.text = [content objectAtIndex:4];
    replyDateLabel.textColor = [UIColor colorWithHex:@"969696"];
    replyDateLabel.backgroundColor = [UIColor clearColor];
    [replyDateLabel sizeToFit];
    [_mainView addSubview:replyDateLabel];
    
    FXLabel *replyLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(replyDateLabel.frame)+10, 320-20, 0)];
    replyLabel.lineSpacing = 0.2;
    replyLabel.lineBreakMode = NSLineBreakByCharWrapping;
    replyLabel.font = [UIFont systemFontOfSize:14];
    replyLabel.numberOfLines = 0;
    replyLabel.text = [content objectAtIndex:5];
    replyLabel.textColor = [UIColor colorWithHex:@"505050"];
    replyLabel.backgroundColor = [UIColor clearColor];
    [replyLabel sizeToFit];
    [_mainView addSubview:replyLabel];
    
    return CGRectGetMaxY(replyLabel.frame);
}

@end

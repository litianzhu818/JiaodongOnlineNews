//
//  JDOReviewListController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-8.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOReviewListController.h"
#import "JDOCommentModel.h"
#import "JDONewsReviewCell.h"
#import "NIFoundationMethods.h"
#import "DCParserConfiguration.h"
#import "DCKeyValueObjectMapping.h"
#import "DCArrayMapping.h"
#import "JDOArrayModel.h"
#import "JDOQuestionCommentModel.h"

@interface JDOReviewListController ()

@property (nonatomic,assign) JDOReviewType type;

@end

#warning 新闻的评论列表应该可以直接添加评论,在下方增加输入框
@implementation JDOReviewListController

-(id)initWithType:(JDOReviewType)type params:(NSDictionary *)params{
    if( type == JDOReviewTypeNews ){
        self = [super initWithServiceName:VIEW_COMMENT_SERVICE modelClass:@"JDOCommentModel" title:@"热门评论" params:[params mutableCopy] needRefreshControl:true];
    }else if( type == JDOReviewTypeLivehood ){
        self = [super initWithServiceName:QUESTION_COMMENT_LIST_SERVICE modelClass:@"JDOArrayModel" title:@"热门评论" params:[params mutableCopy] needRefreshControl:true];
    }
    self.type = type;
    return self;
}

- (void)loadView{
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self.viewDeckController action:@selector(backToDetailList)];
    [self.navigationView setTitle:self.title];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 评论列表
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = false;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.tableView = nil;
}

- (void) backToDetailList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

- (void)loadDataFromNetwork{
    
    if( self.type == JDOReviewTypeNews ){
        [super loadDataFromNetwork];
    }else if( self.type == JDOReviewTypeLivehood ){
        DCParserConfiguration *config = [DCParserConfiguration configuration];
        DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOQuestionCommentModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
        [config addArrayMapper:mapper];
        
        [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_COMMENT_LIST_SERVICE modelClass:@"JDOArrayModel" config:config params:self.listParam success:^(JDOArrayModel *dataModel) {
            if(dataModel != nil && [dataModel.status intValue] ==1 && dataModel.data != nil){
                NSArray *dataArray = (NSArray *)dataModel.data;
                [self setCurrentState:ViewStatusNormal];
                [self dataLoadFinished:dataArray];
            }else{
                // 服务器端有错误
            }
        } failure:^(NSString *errorStr) {
            NSLog(@"错误内容--%@", errorStr);
            [super setCurrentState:ViewStatusRetry];
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.listArray.count == 0){
        return 1;
    }
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"commentIdentifier";
    
    JDONewsReviewCell *cell = (JDONewsReviewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDONewsReviewCell alloc] initWithReuseIdentifier:identifier];
    }
    if(self.listArray.count == 0){
        if(_type == JDOReviewTypeNews){
            [cell setNewsModel:nil];
        }else{
            [cell setQuestionModel:nil];
        }
    }else{
        if(_type == JDOReviewTypeNews){
            [cell setNewsModel:[self.listArray objectAtIndex:indexPath.row]];
        }else{
            [cell setQuestionModel:[self.listArray objectAtIndex:indexPath.row]];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count == 0){
        return 30;
    }else{
        NSString *content;
        if(_type == JDOReviewTypeNews){
            JDOCommentModel *commentModel = [self.listArray objectAtIndex:indexPath.row];
            content = commentModel.content;
        }else if(_type == JDOReviewTypeLivehood){
            JDOQuestionCommentModel *commentModel = [self.listArray objectAtIndex:indexPath.row];
            content = commentModel.liuyan;
        }
        float contentHeight = NISizeOfStringWithLabelProperties(content, CGSizeMake(300, MAXFLOAT), [UIFont systemFontOfSize:Review_Font_Size], UILineBreakModeWordWrap, 0).height;
        return contentHeight + Comment_Name_Height + 10+15 /*上下边距*/ +5 /*间隔*/ ;
    }
}

@end

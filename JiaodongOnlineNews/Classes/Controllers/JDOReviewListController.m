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
#import "SVPullToRefresh.h"

@interface JDOReviewListController ()

@property (nonatomic,assign) JDOReviewType type;
@property (nonatomic,strong) DCParserConfiguration *config;
@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;
@property (nonatomic,strong) JDOToolBar *toolbar;

@end

@implementation JDOReviewListController

-(id)initWithType:(JDOReviewType)type params:(NSDictionary *)params{
    if( type == JDOReviewTypeNews ){
        self = [super initWithServiceName:VIEW_COMMENT_SERVICE modelClass:@"JDOCommentModel" title:@"新闻评论" params:[params mutableCopy] needRefreshControl:true];
    }else if( type == JDOReviewTypeLivehood ){
        self = [super initWithServiceName:QUESTION_COMMENT_LIST_SERVICE modelClass:@"JDOArrayModel" title:@"问题评论" params:[params mutableCopy] needRefreshControl:true];
    }
    self.type = type;
    
    _config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOQuestionCommentModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [_config addArrayMapper:mapper];
    
    return self;
}

- (void)loadView{
    [super loadView];
    
    if( self.type == JDOReviewTypeNews ){
        self.tableView.frame = CGRectMake(0, 44, 320, App_Height-44-44);
        self.noDataView.frame = CGRectMake(0, 44, 320, App_Height-44-44);
        
        // 添加评论栏
        NSArray *toolbarBtnConfig = @[ [NSNumber numberWithInt:ToolBarInputField], [NSNumber numberWithInt:ToolBarButtonReview] ];
        NSArray *widthConfig = @[ @{@"frameWidth":[NSNumber numberWithFloat:270.0f],@"controlWidth":[NSNumber numberWithFloat:240.0f],@"controlHeight":[NSNumber numberWithFloat:28.0f]}, @{@"frameWidth":[NSNumber numberWithFloat:50.0f],@"controlWidth":[NSNumber numberWithFloat:47.0f],@"controlHeight":[NSNumber numberWithFloat:47.0f]} ];
        self.toolbar = [[JDOToolBar alloc] initWithModel:self.model parentController:self typeConfig:toolbarBtnConfig widthConfig:widthConfig frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];// 背景有透明渐变,高度是56不是44
        [self.view addSubview:self.toolbar];
    }
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
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.toolbar action:@selector(hideReviewView)];
    _blackMask = self.view.blackMask;
    [_blackMask addGestureRecognizer:self.closeReviewGesture];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [self setToolbar:nil];
    
    [_blackMask removeGestureRecognizer:self.closeReviewGesture];
}

- (void) backToDetailList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

- (void)loadDataFromNetwork{
    
    if( self.type == JDOReviewTypeNews ){
        [super loadDataFromNetwork];
    }else if( self.type == JDOReviewTypeLivehood ){
        self.noDataView.hidden = true;
        if(![Reachability isEnableNetwork]){
            [self setCurrentState:ViewStatusNoNetwork];
            return;
        }else{  // 从网络加载数据，切换到loading状态
            [self setCurrentState:ViewStatusLoading];
        }
        [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_COMMENT_LIST_SERVICE modelClass:@"JDOArrayModel" config:_config params:self.listParam success:^(JDOArrayModel *dataModel) {
            [self setCurrentState:ViewStatusNormal];
            if(dataModel != nil && [dataModel.status intValue] ==1 ){
                NSArray *dataArray = (NSArray *)dataModel.data;
                if (dataArray == nil || dataArray.count == 0){
                    self.noDataView.hidden = false;
                }else{
                    
                }
                [self dataLoadFinished:dataArray];
            }else{
                NSLog(@"服务器错误,错误代码:%d",[dataModel.status intValue]);
                [super setCurrentState:ViewStatusRetry];
            }
        } failure:^(NSString *errorStr) {
            NSLog(@"错误内容--%@", errorStr);
            [super setCurrentState:ViewStatusRetry];
        }];
    }
}

- (void) refresh{
    
    if( self.type == JDOReviewTypeNews ){
        [super refresh];
    }else if( self.type == JDOReviewTypeLivehood ){
        if(![Reachability isEnableNetwork]){
            [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
            [self.tableView.pullToRefreshView stopAnimating];
            return ;
        }
        
        self.currentPage = 1;
        [self.listParam setObject:@1 forKey:@"p"];
        
        [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_COMMENT_LIST_SERVICE modelClass:@"JDOArrayModel" config:_config params:self.listParam success:^(JDOArrayModel *dataModel) {
            [self.tableView.pullToRefreshView stopAnimating];
            if(dataModel != nil && [dataModel.status intValue] ==1 ){
                NSArray *dataArray = (NSArray *)dataModel.data;
                if (dataArray == nil || dataArray.count == 0){
                    self.noDataView.hidden = false;
                }else{
                    self.noDataView.hidden = true;
                }
                [self dataLoadFinished:dataArray];
            }else{
                NSLog(@"服务器错误,错误代码:%d",[dataModel.status intValue]);
                [JDOCommonUtil showHintHUD:@"服务器错误" inView:self.view];
            }
            
        } failure:^(NSString *errorStr) {
            [self.tableView.pullToRefreshView stopAnimating];
            [JDOCommonUtil showHintHUD:errorStr inView:self.view];
        }];
    }
}

- (void) loadMore{
    if( self.type == JDOReviewTypeNews ){
        [super loadMore];
    }else if( self.type == JDOReviewTypeLivehood ){
        if(![Reachability isEnableNetwork]){
            [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
            [self.tableView.infiniteScrollingView stopAnimating];
            return ;
        }
        
        self.currentPage += 1;
        [self.listParam setObject:[NSNumber numberWithInt:self.currentPage] forKey:@"p"];
        
        [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_COMMENT_LIST_SERVICE modelClass:@"JDOArrayModel" config:_config params:self.listParam success:^(JDOArrayModel *dataModel) {
            [self.tableView.infiniteScrollingView stopAnimating];
            bool finished = false;
            if(dataModel != nil && [dataModel.status intValue] ==1 ){
                NSArray *dataList = (NSArray *)dataModel.data;
                if(dataList == nil || dataList.count == 0){    // 数据加载完成
                    finished = true;
                }else{
                    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.pageSize];
                    for(int i=0;i<dataList.count;i++){
                        [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
                    }
                    [self.listArray addObjectsFromArray:dataList];
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                    [self.tableView endUpdates];
                    
                    if(dataList.count < self.pageSize){
                        finished = true;
                    }
                }
            }else{
                NSLog(@"服务器错误,错误代码:%d",[dataModel.status intValue]);
                [JDOCommonUtil showHintHUD:@"服务器错误" inView:self.view];
            }
            if(finished){
                // 延时执行是为了给insertRowsAtIndexPaths的动画留出时间
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if([self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag]){
                        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
                    }else{
                        UILabel *finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.infiniteScrollingView.bounds.size.width, self.tableView.infiniteScrollingView.bounds.size.height)];
                        finishLabel.textAlignment = NSTextAlignmentCenter;
                        finishLabel.text = All_Data_Load_Finished;
                        finishLabel.tag = Finished_Label_Tag;
                        finishLabel.backgroundColor = [UIColor clearColor];
                        [self.tableView.infiniteScrollingView setEnabled:false];
                        [self.tableView.infiniteScrollingView addSubview:finishLabel];
                    }
                });
            }
        } failure:^(NSString *errorStr) {
            [self.tableView.infiniteScrollingView stopAnimating];
            [JDOCommonUtil showHintHUD:errorStr inView:self.view];
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
        return 0; 
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

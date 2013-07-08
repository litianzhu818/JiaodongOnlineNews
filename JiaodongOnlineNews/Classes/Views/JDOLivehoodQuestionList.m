//
//  JDOLivehoodQuestionList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodQuestionList.h"
#import "JDOQuestionModel.h"
#import "JDOQuestionCell.h"
#import "SVPullToRefresh.h"
//#import "JDOQuestionDetailController.h"
#import "JDOCenterViewController.h"

#define QuestionList_Page_Size 20
#define Finished_Label_Tag 111

@interface JDOLivehoodQuestionList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) NSString *deptCode;
@property (nonatomic,strong) UIImageView *searchBar;
@property (nonatomic,strong) UITextField *searchField;
@property (nonatomic,strong) UIView *maskView;
@property (nonatomic,strong) UIButton *fakeSearchField;

@property (strong, nonatomic) UIImageView *searchPanel;
@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;

@end

@implementation JDOLivehoodQuestionList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
    BOOL _isKeyboardShowing;
    CGRect searchBarOriginFrame;
    CGRect searchBarNewFrame;
    
    CGRect endFrame;
    NSTimeInterval timeInterval;
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info rootView:(UIView *)rootView{
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        self.rootView = rootView;
        self.currentPage = 1;
        self.listArray = [[NSMutableArray alloc] initWithCapacity:QuestionList_Page_Size];
        
        self.reuseIdentifier = [info valueForKey:@"reuseId"];
        CGRect tableFrame = self.bounds;
        tableFrame.size.height = tableFrame.size.height-53 /*搜索框高度*/;
        self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = News_Cell_Height;
        [self addSubview:self.tableView];
        
        __block JDOLivehoodQuestionList *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
        }];
        
        // 搜索框
        searchBarOriginFrame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame), 320, 53);
        self.searchBar = [[UIImageView alloc] initWithFrame:searchBarOriginFrame];
        self.searchBar.image = [UIImage imageNamed:@"livehood_search_background"];
        self.searchBar.userInteractionEnabled = true;
        _fakeSearchField = [UIButton buttonWithType:UIButtonTypeCustom];
        _fakeSearchField.frame = CGRectMake(10,13,220,40);
        _fakeSearchField.backgroundColor = [UIColor whiteColor];
        [_fakeSearchField setTitle:@"请输入关键词或编号" forState:UIControlStateNormal];
        _fakeSearchField.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_fakeSearchField setTitleColor:[UIColor colorWithHex:@"808080"] forState:UIControlStateNormal];
        [_fakeSearchField addTarget:self action:@selector(showSearchPanel) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *entryBackground = [[UIImage imageNamed:@"MessageEntryInputField.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(10, 13, 220, 40);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImage *background = [[UIImage imageNamed:@"MessageEntryBackground.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0, 13, 320, 40);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.searchBar addSubview:imageView];
        [self.searchBar addSubview:_fakeSearchField];
        [self.searchBar addSubview:entryImageView];
        
        UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        submitBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        submitBtn.frame = CGRectMake(320-10-60, 13+8, 60, 27);
        [submitBtn setTitle:@"搜索" forState:UIControlStateNormal];
        [submitBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        submitBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        [self.searchBar addSubview:submitBtn];
        
        [self addSubview:self.searchBar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        [self addSubview:self.statusView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deptChanged:) name:kDeptChangedNotification object:nil];
    }
    return self;
}

- (void) showSearchPanel{
    [SharedAppDelegate deckController].enabled = false;
    
    if( _searchPanel == nil){
        _searchPanel = [[UIImageView alloc] initWithFrame:CGRectMake(0, App_Height-53, 320, 53)];
        _searchPanel.image = [UIImage imageNamed:@"livehood_search_background"];
        _searchPanel.userInteractionEnabled = true;
        
        _searchField = [[UITextField alloc] initWithFrame:CGRectMake(10,23,220,40)];
        _searchField.backgroundColor = [UIColor whiteColor];
        _searchField.placeholder = @"请输入关键词或编号";
        
        UIImage *entryBackground = [[UIImage imageNamed:@"MessageEntryInputField.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(10, 13, 220, 40);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImage *background = [[UIImage imageNamed:@"MessageEntryBackground.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0, 13, 320, 40);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.searchPanel addSubview:imageView];
        [self.searchPanel addSubview:_searchField];
        [self.searchPanel addSubview:entryImageView];
        
        UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        submitBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        submitBtn.frame = CGRectMake(320-10-60, 13+8, 60, 27);
        [submitBtn setTitle:@"搜索" forState:UIControlStateNormal];
        [submitBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        submitBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        [self.searchPanel addSubview:submitBtn];
        
    }
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchPanel)];
    _maskView = self.rootView.blackMask;
    [self.maskView addGestureRecognizer:self.closeReviewGesture];
    
    [self.rootView pushView:_searchPanel process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        [_searchField becomeFirstResponder];
        _isKeyboardShowing = true;
        *_startFrame = _searchPanel.frame;
        *_endFrame = endFrame;
        *_timeInterval = timeInterval;
    } complete:^{
        
    }];
}

- (void) hideSearchPanel{
    [SharedAppDelegate deckController].enabled = true;
    [_searchField resignFirstResponder];
    _isKeyboardShowing = false;
    [_searchPanel popView:self.rootView process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        *_startFrame = _searchPanel.frame;
        *_endFrame = CGRectMake(0, App_Height-_searchPanel.frame.size.height, 320, _searchPanel.frame.size.height);
        *_timeInterval = timeInterval;
    } complete:^{
        [_searchPanel removeFromSuperview];
    }];
}


- (void)submitReview:(id)sender{
    
//    if(JDOIsEmptyString(_reviewPanel.textView.text) || [[_reviewPanel.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:Review_Comment_Placeholder]){
//        return;
//    }
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
//    [params setObject:self.model.id forKey:@"aid"];
//    [params setObject:[_reviewPanel.textView.text stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters] forKey:@"content"];
//    [params setObject:@"" forKey:@"nickName"];
//    [params setObject:@"" forKey:@"uid"];
//    [params setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"deviceId"];
//    
//    [[JDOHttpClient sharedClient] getJSONByServiceName:[self.model reviewService] modelClass:nil params:params success:^(NSDictionary *result) {
//        NSNumber *status = [result objectForKey:@"status"];
//        if([status intValue] == 1 || [status intValue] == 2){ // 1:提交成功 2:重复提交,隐藏键盘
//            // 清空内容，重设键盘高度
//            _reviewPanel.textView.text = nil;
//            _reviewPanel.frame = [_reviewPanel initialFrame];
//            [_reviewPanel.remainWordNum setHidden:true];
//            [self hideSearchPanel];
//        }else if([status intValue] == 0){
//            // 提交失败,服务器错误
//            NSLog(@"提交失败,服务器错误");
//            [JDOCommonUtil showHintHUD:@"服务器错误" inView:self.parentView];
//        }
//    } failure:^(NSString *errorStr) {
//#warning 评论时的错误在页面上显示不出来提示
//        NSLog(@"错误内容--%@", errorStr);
//        [JDOCommonUtil showHintHUD:errorStr inView:self.parentView];
//    }];
}

#pragma mark - keyboard notification

// 显示键盘和切换输入法时都会执行
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.rootView.superview convertRect:keyboardRect fromView:nil];
    
    CGRect searchPanelFrame = _searchPanel.frame;
    searchPanelFrame.origin.y = self.rootView.bounds.size.height - (keyboardRect.size.height + searchPanelFrame.size.height);
    CGRect _endFrame = searchPanelFrame;
    
    if( _isKeyboardShowing == false){
        endFrame = _endFrame;
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [animationDurationValue getValue:&timeInterval];
    }else{
        _searchPanel.frame = _endFrame;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [animationDurationValue getValue:&timeInterval];
}


- (void) deptChanged:(NSNotification *)notification{
    NSString *deptCode = [notification.userInfo objectForKey:@"dept_code"];
    if( ![_deptCode isEqualToString:deptCode] ){
        _deptCode = deptCode;
        [self loadDataFromNetwork];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeptChangedNotification object:nil];
    [self.blackMask removeGestureRecognizer:self.closeReviewGesture];
}

- (void) setCurrentState:(ViewStatusType)status{
    self.status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.tableView.hidden = false;
        self.searchBar.hidden = false;
    }else{
        self.tableView.hidden = true;
        self.searchBar.hidden = true;
    }
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (NSDictionary *) listParam{
    return @{@"dept_code":self.deptCode,@"p":[NSNumber numberWithInt:self.currentPage],@"pageSize":@QuestionList_Page_Size};
}

- (void)loadDataFromNetwork{
    [self setCurrentState:ViewStatusLoading];

    [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_LIST_SERVICE modelClass:@"JDOQuestionModel" params:self.listParam success:^(NSArray *dataList) {
        if(dataList != nil && dataList.count >0){
            [self setCurrentState:ViewStatusNormal];
            [self dataLoadFinished:dataList];
        }else{  
            // dataList.count == 0的情况需要在tableview的datasource中处理，例如评论列表中提示"暂无评论"
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (void) refresh{
    self.currentPage = 1;
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_LIST_SERVICE modelClass:@"JDOQuestionModel" params:self.listParam success:^(NSArray *dataList)  {
        if(dataList != nil && dataList.count >0){
            [self.tableView.pullToRefreshView stopAnimating];
            [self dataLoadFinished:dataList];
        }else{
            // dataList.count == 0的情况需要在tableview的datasource中处理，例如评论列表中提示"暂无评论"
        }
    } failure:^(NSString *errorStr) {
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (void) dataLoadFinished:(NSArray *)dataList{
    [self.listArray removeAllObjects];
    [self.listArray addObjectsFromArray:dataList];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    [self updateLastRefreshTime];
    if( dataList.count<QuestionList_Page_Size ){
        [self.tableView.infiniteScrollingView setEnabled:false];
        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
    }else{
        [self.tableView.infiniteScrollingView setEnabled:true];
        [self.tableView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
    }
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (void) loadMore{
    self.currentPage += 1;

    [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_LIST_SERVICE modelClass:@"JDOQuestionModel" params:self.listParam success:^(NSArray *dataList) {
        bool finished = false;
        if(dataList == nil || dataList.count == 0){    // 数据加载完成
            [self.tableView.infiniteScrollingView stopAnimating];
            finished = true;
        }else if(dataList.count >0){
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:QuestionList_Page_Size];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
            [self.tableView.infiniteScrollingView stopAnimating];
            if(dataList.count < QuestionList_Page_Size){
                finished = true;
            }
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
                    finishLabel.text = All_Date_Load_Finished;
                    finishLabel.tag = Finished_Label_Tag;
                    [self.tableView.infiniteScrollingView setEnabled:false];
                    [self.tableView.infiniteScrollingView addSubview:finishLabel];
                }
            });
        }
    } failure:^(NSString *errorStr) {
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.listArray.count == 0){
        return 1;
    }
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Question_Cell";
    
    JDOQuestionCell *cell = (JDOQuestionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[JDOQuestionCell alloc] initWithReuseIdentifier:identifier];
    }
    if(self.listArray.count == 0){
        [cell setModel:nil];
    }else{
        [cell setModel:[self.listArray objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count == 0){
        return 30;
    }else{
        JDOQuestionModel *questionModel = [self.listArray objectAtIndex:indexPath.row];
        return [self cellHeight:questionModel];
    }
}

- (CGFloat) cellHeight:(JDOQuestionModel *) model {
    float titieHeight = NISizeOfStringWithLabelProperties(model.title, CGSizeMake(300, MAXFLOAT), [UIFont systemFontOfSize:Title_Font_Size], UILineBreakModeWordWrap, 0).height;
    return 10+Dept_Label_Height+titieHeight+Code_Label_Height+3*Cell_Padding+1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:[self.listArray objectAtIndex:indexPath.row]];
//    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
//    [centerController pushViewController:detailController animated:true];
//    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end

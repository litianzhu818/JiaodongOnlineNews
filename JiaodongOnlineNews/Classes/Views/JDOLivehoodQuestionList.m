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
#import "JDOQuestionDetailController.h"
#import "JDOCenterViewController.h"
#import "FXLabel.h"
#import "InsetsTextField.h"
#import "CustomIOS7AlertView.h"
#import "DCParserConfiguration.h"
#import "DCArrayMapping.h"
#import "JDOArrayModel.h"
//#import "XYInputView.h"

#define QuestionList_Page_Size 20
#define Finished_Label_Tag 111
#define Secret_Field_Tag 101
#define Search_Placeholder @"请输入关键词或编号"

@interface JDOLivehoodQuestionList () <UIAlertViewDelegate>

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) NSString *deptCode;
@property (nonatomic,strong) UIImageView *searchBar;
@property (nonatomic,strong) InsetsTextField *searchField;
@property (nonatomic,strong) UIView *maskView;
@property (nonatomic,strong) FXLabel *fakeSearchField;

@property (strong, nonatomic) UIImageView *searchPanel;
@property (strong, nonatomic) UITapGestureRecognizer *closeInputGesture;
@property (strong, nonatomic) UITapGestureRecognizer *openInputGesture;

@property (strong,nonatomic) UIImageView *noDataView;
@property (strong,nonatomic) UIAlertView *alertView;
@property (strong,nonatomic) CustomIOS7AlertView *iOS7AlertView;

@end

@implementation JDOLivehoodQuestionList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
    BOOL _isKeyboardShowing;
    CGRect searchBarOriginFrame;
    CGRect searchBarNewFrame;
    
    CGRect endFrame;
    NSTimeInterval timeInterval;
    JDOQuestionModel *secretQuestionModel;
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info rootView:(UIView *)rootView{
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        self.rootView = rootView;
        self.currentPage = 1;
        self.listArray = [[NSMutableArray alloc] initWithCapacity:QuestionList_Page_Size];
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
        self.reuseIdentifier = [info valueForKey:@"reuseId"];
        CGRect tableFrame = self.bounds;
        tableFrame.size.height = tableFrame.size.height-44 /*搜索框实际高度*/;
        self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
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
        _fakeSearchField = [[FXLabel alloc] initWithFrame:CGRectMake(10,9+7,240,30)];
        _fakeSearchField.textInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        _fakeSearchField.userInteractionEnabled = true;
        _fakeSearchField.backgroundColor = [UIColor whiteColor];
        _fakeSearchField.textAlignment = NSTextAlignmentLeft;
        _fakeSearchField.textColor = [UIColor colorWithHex:@"c8c8c8"];
//        _fakeSearchField.enabled = false;
        _fakeSearchField.text = Search_Placeholder;
        _openInputGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSearchPanel)];
        [_fakeSearchField addGestureRecognizer:_openInputGesture];
        
        self.searchBar = [self buildSearchBar:_fakeSearchField];
        [self addSubview:self.searchBar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        self.statusView.delegate = self;
        [self addSubview:self.statusView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deptChanged:) name:kDeptChangedNotification object:nil];
        
        // 无数据提示
        _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_no_data"]];
        _noDataView.frame = CGRectMake(0, -44, 320, self.bounds.size.height);
        _noDataView.hidden = true;
        [self addSubview:_noDataView];
        
    }
    return self;
}

- (UIImageView *) buildSearchBar:(UIView *)inputField {
    CGRect frame, backgroundFrame, inputMaskFrame, submitBtnFrame;
    SEL searchBtnClicked = nil;
    NSString *backgroudImageName;
    if([inputField isKindOfClass:[UILabel class]]){
        frame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame)-(53-44), 320, 53);
        backgroundFrame = CGRectMake(0, 0, 320, 53);
        inputMaskFrame = CGRectMake(0, 9, 320, 44);
        submitBtnFrame = CGRectMake(320-10-55, (53-44)+(44-30)/2, 55, 30);
        searchBtnClicked = @selector(fakeBtnClicked:);
        backgroudImageName = @"inputFieldType1";
    }else{  // UITextField
        frame = CGRectMake(0, App_Height-44, 320, 44);
        backgroundFrame = CGRectMake(0, 0, 320, 44);
        inputMaskFrame = CGRectMake(0, 0, 320, 44);
        submitBtnFrame = CGRectMake(320-10-55, (44-30)/2, 55, 30);
        searchBtnClicked = @selector(sendBtnClicked:);
        backgroudImageName = @"inputFieldType2";
    }
    UIImageView *searchBar = [[UIImageView alloc] initWithFrame:frame];
//    searchBar.image = [UIImage imageNamed:@"livehood_search_background"];
    searchBar.userInteractionEnabled = true;
    
    UIImageView *inputMask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inputField"]];
    inputMask.frame = inputMaskFrame;
    inputMask.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroudImageName]];
    background.frame = backgroundFrame;
    background.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    
    [searchBar addSubview:background];
    [searchBar addSubview:inputField];
    [searchBar addSubview:inputMask];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    submitBtn.frame = submitBtnFrame;
    [submitBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [submitBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    submitBtn.titleLabel.shadowOffset = Is_iOS7?CGSizeMake(0, 0):CGSizeMake(0, -1);
    submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString *btnBackground = Is_iOS7?@"input_btn~iOS7":@"input_btn";
    [submitBtn setBackgroundImage:[UIImage imageNamed:btnBackground] forState:UIControlStateNormal];
    [submitBtn setBackgroundImage:[UIImage imageNamed:btnBackground] forState:UIControlStateSelected];
    [submitBtn addTarget:self action:searchBtnClicked forControlEvents:UIControlEventTouchUpInside];
    
    [searchBar addSubview:submitBtn];
    
    return searchBar;
}

- (void) sendBtnClicked:(UIButton *)searchBtn {
    [self hideSearchPanel:nil];
}

- (void) fakeBtnClicked:(UIButton *)searchBtn {
    [self loadDataFromNetwork];
}

- (void) showSearchPanel{
    [SharedAppDelegate deckController].enabled = false;
    
    if( _searchPanel == nil){
        _searchField = [[InsetsTextField alloc] initWithFrame:CGRectMake(10,7,240,30)];
        _searchField.backgroundColor = [UIColor whiteColor];
        _searchField.placeholder = Search_Placeholder;
        
        _searchPanel = [self buildSearchBar:_searchField];
    }
    
    _closeInputGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearchPanel:)];
    _maskView = self.rootView.blackMask;
    [self.maskView addGestureRecognizer:_closeInputGesture];
    
    [self.rootView pushView:_searchPanel process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        [_searchField becomeFirstResponder];
        _isKeyboardShowing = true;
        *_startFrame = _searchPanel.frame;
        *_endFrame = endFrame;
        *_timeInterval = timeInterval;
    } complete:^{
        
    }];
}

- (void) hideSearchPanel:(UIGestureRecognizer *)gesture{
    [SharedAppDelegate deckController].enabled = true;
    
    // 把_searchField的内容复制到_fakeSearchField
    if(!JDOIsEmptyString(_searchField.text)){
//        _fakeSearchField.enabled = true;
        _fakeSearchField.textColor = [UIColor colorWithHex:@"505050"];
        _fakeSearchField.text = _searchField.text;
    }else{
//        _fakeSearchField.enabled = false;
        _fakeSearchField.textColor = [UIColor colorWithHex:@"c8c8c8"];
        _fakeSearchField.text = Search_Placeholder;
    }
    // 关闭输入窗口
    [_searchField resignFirstResponder];
    _isKeyboardShowing = false;
    
    [_searchPanel popView:self.rootView process:^(CGRect *_startFrame, CGRect *_endFrame, NSTimeInterval *_timeInterval) {
        *_startFrame = _searchPanel.frame;
        *_endFrame = CGRectMake(0, App_Height-_searchPanel.frame.size.height, 320, _searchPanel.frame.size.height);
        *_timeInterval = timeInterval;
    } complete:^{
        [_searchPanel removeFromSuperview];
        if(gesture == nil){
            [self loadDataFromNetwork];
        }
    }];
}


#pragma mark - keyboard notification

// 显示键盘和切换输入法时都会执行
- (void)keyboardWillShow:(NSNotification *)notification{
    if(!JDOIsVisiable(self)){
        return;
    }
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
    if(!JDOIsVisiable(self)){
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [animationDurationValue getValue:&timeInterval];
}


- (void) deptChanged:(NSNotification *)notification{
    NSString *deptCode = [notification.userInfo objectForKey:@"dept_code"];
    if( ![_deptCode isEqualToString:deptCode] ){
        _deptCode = deptCode;
        // 切换部门时清空查询条件
        _fakeSearchField.text = Search_Placeholder;
        _fakeSearchField.textColor = [UIColor colorWithHex:@"c8c8c8"];
        _searchField.text = nil;
        [self loadDataFromNetwork];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeptChangedNotification object:nil];
    [self.blackMask removeGestureRecognizer:self.closeInputGesture];
    [self.fakeSearchField removeGestureRecognizer:self.openInputGesture];
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
    NSMutableDictionary *listParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:self.currentPage],@"p",@QuestionList_Page_Size,@"pageSize",nil];
    
    if (!JDOIsEmptyString(self.deptCode) && ![self.deptCode isEqualToString:@"ALL"]){
        [listParam setObject:self.deptCode forKey:@"dept_code"];
    }
    
    if (!JDOIsEmptyString(_fakeSearchField.text) && ![[_fakeSearchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:Search_Placeholder]){
        [listParam setObject:_fakeSearchField.text forKey:@"keywords"];
    }
    return listParam;
}

- (void)loadDataFromNetwork{
    self.noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }

    // 有可能再翻页之后再进行搜索,所以需要将页码置为1
    self.currentPage = 1;
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOQuestionModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_LIST_SERVICE modelClass:@"JDOArrayModel" config:config params:[self listParam] success:^(JDOArrayModel *model) {
        NSArray *dataList = model.data;
        [self setCurrentState:ViewStatusNormal];
        if(dataList == nil || dataList.count == 0){
            // 搜索时很有可能返回结果为空
            _noDataView.hidden = false;
        }else{
            
        }
        [self dataLoadFinished:dataList];
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    
    self.currentPage = 1;
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOQuestionModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_LIST_SERVICE modelClass:@"JDOArrayModel" config:config params:[self listParam] success:^(JDOArrayModel *model)  {
        NSArray *dataList = model.data;
        [self.tableView.pullToRefreshView stopAnimating];
        if(dataList == nil || dataList.count == 0){
            self.noDataView.hidden = false;
        }else{
            self.noDataView.hidden = true;
        }
        [self dataLoadFinished:dataList];
    } failure:^(NSString *errorStr) {
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (void) dataLoadFinished:(NSArray *)dataList{
    [self.listArray removeAllObjects];
    [self.listArray addObjectsFromArray:dataList];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    
    // 因为可能在翻了多页之后点查询,此时列表重新加载数据后会停留在最下方
    if (self.listArray.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:false];
    }
    
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
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }
    self.currentPage += 1;
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOQuestionModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_LIST_SERVICE modelClass:@"JDOArrayModel" config:config params:[self listParam] success:^(JDOArrayModel *model) {
        NSArray *dataList = model.data;
        [self.tableView.infiniteScrollingView stopAnimating];
        bool finished = false;
        if(dataList == nil || dataList.count == 0){    // 数据加载完成
            finished = true;
        }else{
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:QuestionList_Page_Size];
            for(int i=0;i<dataList.count;i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.listArray.count+i inSection:0]];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
            
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
        return 0;
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
    JDOQuestionModel *questionModel = [self.listArray objectAtIndex:indexPath.row];
    BOOL enable = false;
    if ([questionModel.secret intValue] == 1) { // 保密
        secretQuestionModel = questionModel;
        if([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
            if(_iOS7AlertView == nil){
                _iOS7AlertView = [[CustomIOS7AlertView alloc] initWithParentView:SharedAppDelegate.window];
                _iOS7AlertView.delegate = self;
                UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 260, 90)];
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 240, 25)];
                title.textAlignment = UITextAlignmentCenter;
                title.text = @"请输入查询密码";
                title.font = [UIFont boldSystemFontOfSize:18];
                title.backgroundColor = [UIColor clearColor];
                [containView addSubview:title];
                InsetsTextField *secretTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(10,50, 240, 35)];
                secretTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                secretTextField.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
                secretTextField.secureTextEntry = YES;
                secretTextField.placeholder = @"6位数字";
                secretTextField.keyboardType = UIKeyboardTypeNumberPad;
                secretTextField.tag = Secret_Field_Tag;
                [containView addSubview:secretTextField];
                _iOS7AlertView.containerView = containView;
                _iOS7AlertView.buttonTitles = @[@"确认",@"取消"];
            }
            [_iOS7AlertView show];
        }else{
            if (_alertView == nil) {
                _alertView = [[UIAlertView alloc] initWithTitle:@"请输入查询密码" message:@"\n\n" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
                InsetsTextField *secretTextField = [[InsetsTextField alloc] initWithFrame:CGRectMake(12.0f, 51.0f, 260.0f, 35.0f)];
                secretTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                secretTextField.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
                secretTextField.secureTextEntry = YES;
                secretTextField.placeholder = @"6位数字";
                secretTextField.keyboardType = UIKeyboardTypeNumberPad;
                secretTextField.tag = Secret_Field_Tag;
                [_alertView addSubview:secretTextField];
            }
            [_alertView show];
        }
        
    }else{
        enable = true;
    }
    
    if(enable){
        JDOQuestionDetailController *detailController = [[JDOQuestionDetailController alloc] initWithQuestionModel:questionModel];
        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
        [centerController pushViewController:detailController animated:true];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){   // 取消
        [(UITextField *)[alertView.containerView viewWithTag:Secret_Field_Tag] setText:nil];
        [alertView close];
    }else{
        NSString *secret = [(UITextField *)[alertView.containerView viewWithTag:Secret_Field_Tag] text];
        if(JDOIsEmptyString(secret)){
            return;
        }
        [(UITextField *)[alertView.containerView viewWithTag:Secret_Field_Tag] setText:nil];
        [alertView close];
        if ( [secret isEqualToString:secretQuestionModel.pwd] ) {   // 密码正确
            JDOQuestionDetailController *detailController = [[JDOQuestionDetailController alloc] initWithQuestionModel:secretQuestionModel];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:detailController animated:true];
        }else{
            [JDOCommonUtil showHintHUD:@"密码错误,请重新输入" inView:self];
            [(UITextField *)[alertView.containerView viewWithTag:Secret_Field_Tag] setText:nil];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == [alertView cancelButtonIndex]){
        
    }else{
        NSString *secret = [(UITextField *)[alertView viewWithTag:Secret_Field_Tag] text];
        if(JDOIsEmptyString(secret)){
            return;
        }
        if ( [secret isEqualToString:secretQuestionModel.pwd] ) {   // 密码正确
            JDOQuestionDetailController *detailController = [[JDOQuestionDetailController alloc] initWithQuestionModel:secretQuestionModel];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:detailController animated:true];
        }else{
            [JDOCommonUtil showHintHUD:@"密码错误,请重新输入" inView:self];
            [(UITextField *)[_alertView viewWithTag:Secret_Field_Tag] setText:nil];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ( alertView == _alertView) {
        [(UITextField *)[_alertView viewWithTag:Secret_Field_Tag] setText:nil];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView{
    if ( alertView == _alertView) { // 显示键盘
        [[_alertView viewWithTag:Secret_Field_Tag] becomeFirstResponder];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}

- (void)alertViewCancel:(UIAlertView *)alertView{

}





@end

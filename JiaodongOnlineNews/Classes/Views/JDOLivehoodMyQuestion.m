//
//  JDOLivehoodMyQuestion.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodMyQuestion.h"
#import "SVPullToRefresh.h"
#import "JDOQuestionCell.h"
#import "JDOQuestionModel.h"
#import "JDOQuestionDetailController.h"

#define QuestionList_Page_Size 20
@interface JDOLivehoodMyQuestion ()

@property (nonatomic,strong) NSDate *lastUpdateTime;

@end

@implementation JDOLivehoodMyQuestion

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info rootView:(UIView *)rootView{
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        self.rootView = rootView;
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
        self.reuseIdentifier = [info valueForKey:@"reuseId"];
        CGRect tableFrame = self.bounds;
        tableFrame.size.height = tableFrame.size.height-44 /*搜索框实际高度*/;
        self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = News_Cell_Height;
        [self.tableView setHidden:YES];
        [self addSubview:self.tableView];
        
        __block JDOLivehoodMyQuestion *blockSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
        }];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        [self.statusView setDelegate:self];
        [self addSubview:self.statusView];
        
        // 无数据提示
        _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_no_data"]];
        _noDataView.frame = CGRectMake(0, -44, 320, self.bounds.size.height);
        [_noDataView setHidden:YES];
        [self addSubview:_noDataView];
        self.listArray = [[NSMutableArray alloc] init];
        
        [self.tableView.infiniteScrollingView setEnabled:false];
    }
    return self;
}

- (void)refresh
{
    [self loadDataFromNetwork];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)loadMore
{
    
}

- (NSDictionary *) listParam{
    NSMutableString *ids = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < self.idsArray.count; i++) {
        [ids appendString:[self.idsArray objectAtIndex:i]];
        if (i < self.idsArray.count - 1) {
            [ids appendString:@","];
        }
    }
    NSDictionary *listParam = @{@"info_id": ids, @"checked": @"0", @"pageSize": @"10000"};
    
    return listParam;
}

- (void)loadDataFromNetwork
{
    [self.noDataView setHidden:YES];
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }

    self.idsArray = [NSKeyedUnarchiver unarchiveObjectWithFile: [[SharedAppDelegate cachePath] stringByAppendingPathComponent:@"QuesMessage"]];
    if (self.idsArray) {
        // 有可能再翻页之后再进行搜索,所以需要将页码置为1
        [[JDOHttpClient sharedClient] getJSONByServiceName:QUESTION_LIST_SERVICE modelClass:@"JDOQuestionModel" params:[self listParam] success:^(NSArray *dataList) {
            [self setCurrentState:ViewStatusNormal];
            if(dataList == nil || dataList.count == 0){
                [_noDataView setHidden:NO];
            }else{
                [self.listArray removeAllObjects];
                [self.listArray addObjectsFromArray:dataList];
                [self.tableView reloadData];
                [self.tableView setHidden:NO];
            }
        } failure:^(NSString *errorStr) {
            NSLog(@"错误内容--%@", errorStr);
            [self setCurrentState:ViewStatusRetry];
        }];
    } else {
        [_noDataView setHidden:NO];
        [self setCurrentState:ViewStatusNormal];
    }
}



#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JDOQuestionModel *questionModel = [self.listArray objectAtIndex:indexPath.row];
    
    JDOQuestionDetailController *detailController = [[JDOQuestionDetailController alloc] initWithQuestionModel:questionModel isMyQuestion:YES];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}

#pragma mark -
#pragma mark UITableViewDataSource

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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.listArray.count == 0){
        return 1;
    }
    return self.listArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}



- (void) setCurrentState:(ViewStatusType)status{
    self.status = status;
    self.statusView.status = status;
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

@end

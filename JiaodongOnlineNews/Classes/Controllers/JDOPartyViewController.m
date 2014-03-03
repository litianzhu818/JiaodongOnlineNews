//
//  JDOImageViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOPartyViewController.h"
#import "JDOPartyDetailController.h"
#import "JDOPartyModel.h"
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "JDOPartyCell.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"

#define PartyList_Page_Size 5

@interface JDOPartyViewController ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

@end

@implementation JDOPartyViewController

-(id)init{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@PartyList_Page_Size forKey:@"pageSize"];
    self = [super initWithServiceName:PARTY_SERVICE modelClass:@"JDOPartyModel" title:@"精彩活动" params:params needRefreshControl:true];
    if(self){
        [self setIsCacheToMemory:TRUE andCacheFileName:@"PartyListCache"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.rowHeight = 350.0f;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) setupNavigationView{
    [self.navigationView addLeftButtonImage:@"left_menu_btn" highlightImage:@"left_menu_btn" target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationView addRightButtonImage:@"right_menu_btn" highlightImage:@"right_menu_btn" target:self.viewDeckController action:@selector(toggleRightView)];
    [self.navigationView setTitle:@"精彩活动"];
}

//- (void) onBackBtnClick{
//    JDOCenterViewController *centerViewController = (JDOCenterViewController *)SharedAppDelegate.deckController.centerController;
//    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count==0 ? 10:self.listArray.count;
}

// 加了空section，为了补齐上边距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 18;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 18)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseId = @"PartyCell";
    JDOPartyCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if(cell == nil){
        cell = [[JDOPartyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
    }
    if(self.listArray.count > 0){
        Class _modelClass = NSClassFromString(self.modelClass);
        DCKeyValueObjectMapping *mapper  = [DCKeyValueObjectMapping mapperForClass:_modelClass andConfiguration:[DCParserConfiguration configuration]];
        NSDictionary *partyModel = [self.listArray objectAtIndex:indexPath.row];
        [cell setModel:[mapper parseDictionary:partyModel]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Class _modelClass = NSClassFromString(self.modelClass);
    DCKeyValueObjectMapping *mapper  = [DCKeyValueObjectMapping mapperForClass:_modelClass andConfiguration:[DCParserConfiguration configuration]];
    JDOPartyDetailController *detailController = [[JDOPartyDetailController alloc] initWithPartyModel:[mapper parseDictionary:[self.listArray objectAtIndex:indexPath.row]]];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)loadDataFromNetwork{
    self.noDataView.hidden = true;
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
        return;
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
    }
    [[JDOHttpClient sharedClient] getPath:self.serviceName parameters:self.listParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonResult = [(NSData *)responseObject objectFromJSONData];
        if([jsonResult isKindOfClass:[NSDictionary class]]) {
            NSArray *dataList = [(NSDictionary *)jsonResult objectForKey:@"data"];
            [self setCurrentState:ViewStatusNormal];
            if(dataList == nil || dataList.count == 0){
                self.noDataView.hidden = false;
            }else{
                
            }
            [self dataLoadFinished:dataList];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"错误内容--%@", error);
        [self setCurrentState:ViewStatusRetry];
    }];
}
- (void) refresh{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
        [self.tableView.pullToRefreshView stopAnimating];
        return ;
    }
    
    self.currentPage = 1;
    [self.listParam setObject:@1 forKey:@"p"];
    
    [[JDOHttpClient sharedClient] getPath:self.serviceName parameters:self.listParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonResult = [(NSData *)responseObject objectFromJSONData];
        [self.tableView.pullToRefreshView stopAnimating];
        if([jsonResult isKindOfClass:[NSDictionary class]]) {
            NSArray *dataList = [(NSDictionary *)jsonResult objectForKey:@"data"];
            if(dataList == nil || dataList.count == 0){
                self.noDataView.hidden = false;
            }else{
                self.noDataView.hidden = true;
            }
            [self dataLoadFinished:dataList];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:error.domain inView:self.view];
    }];
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self.view];
        [self.tableView.infiniteScrollingView stopAnimating];
        return ;
    }
    
    self.currentPage += 1;
    [self.listParam setObject:[NSNumber numberWithInt:self.currentPage] forKey:@"p"];
    
    [[JDOHttpClient sharedClient] getPath:self.serviceName parameters:self.listParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id jsonResult = [(NSData *)responseObject objectFromJSONData];
        [self.tableView.infiniteScrollingView stopAnimating];
        bool finished = false;
        if([jsonResult isKindOfClass:[NSDictionary class]]) {
            NSArray *dataList = [(NSDictionary *)jsonResult objectForKey:@"data"];
            if(dataList == nil || dataList.count == 0){
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView.infiniteScrollingView stopAnimating];
        [JDOCommonUtil showHintHUD:error.domain inView:self.view];
    }];
    
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(self.listArray.count == 0){
//        return 0;
//    }else{
//        JDOPartyModel *questionModel = [self.listArray objectAtIndex:indexPath.row];
//        return [self cellHeight:questionModel];
//    }
//}
//
//- (CGFloat) cellHeight:(NSDictionary *) model {
//    float titieHeight = NISizeOfStringWithLabelProperties([model objectForKey:@"title"], CGSizeMake(300, MAXFLOAT), [UIFont systemFontOfSize:18], UILineBreakModeWordWrap, 0).height;
//    return 360+titieHeight;
//}

@end

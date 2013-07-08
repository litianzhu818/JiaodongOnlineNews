//
//  JDOTopicViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOTopicViewController.h"
#import "UIImageView+WebCache.h"
#import "JDOTopicCell.h"
#import "JDOTopicModel.h"
#import "JDOTopicDetailController.h"

#define TopicList_Page_Size 10
#define ScrollView_Tag 108

@interface JDOTopicViewController ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (nonatomic,strong) UIView *detailView;

@end

@implementation JDOTopicViewController{
    BOOL isLoadFinised;
}


-(id)init{
    
    if(self = [super init]){
        self.serviceName = TOPIC_LIST_SERVICE;
        self.listArray = [[NSMutableArray alloc] initWithCapacity : 10];
        self.modelClass = @"JDOTopicModel";
        
        self.listParam = [[NSMutableDictionary alloc] init];
        [self.listParam setObject:@TopicList_Page_Size forKey:@"pageSize"];
        [self.listParam setObject:@1 forKey:@"p"];
        self.currentPage = 1;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
    self.statusView.delegate = self;
    [self.view addSubview:self.statusView];
}

- (void) setupNavigationView{
    [self.navigationView addLeftButtonImage:@"left_menu_btn" highlightImage:@"left_menu_btn" target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationView addRightButtonImage:@"right_menu_btn" highlightImage:@"right_menu_btn" target:self.viewDeckController action:@selector(toggleRightView)];
    [self.navigationView setTitle:@"每日一题"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.horizontalScrollView.hidden = false;
    }else{
        self.horizontalScrollView.hidden = true;
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _horizontalScrollView = [[[NSBundle mainBundle] loadNibNamed:@"HGPageScrollView" owner:self options:nil] objectAtIndex:0];
    _horizontalScrollView.tag = ScrollView_Tag;
	[self.view insertSubview:_horizontalScrollView belowSubview:self.navigationView];
	
    if(![Reachability isEnableNetwork]){
        [self setCurrentState:ViewStatusNoNetwork];
    }else{  // 从网络加载数据，切换到loading状态
        [self setCurrentState:ViewStatusLoading];
        [self loadDataFromNetwork];
    }
	
}

- (void)loadDataFromNetwork{
    
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
        if(dataList == nil){
            isLoadFinised = true;   // 数据加载完成
        }else{
            if(dataList.count < TopicList_Page_Size){   // 数据加载完成
                isLoadFinised = true;   
            }
            [self setCurrentState:ViewStatusNormal];
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self.horizontalScrollView reloadData];
        }
    } failure:^(NSString *errorStr) {
        NSLog(@"错误内容--%@", errorStr);
        [self setCurrentState:ViewStatusRetry];
    }];
}

- (void) loadMore{
    self.currentPage += 1;
    [self.listParam setObject:[NSNumber numberWithInt:self.currentPage] forKey:@"p"];
    [[JDOHttpClient sharedClient] getJSONByServiceName:_serviceName modelClass:self.modelClass params:self.listParam success:^(NSArray *dataList) {
        if(dataList == nil || dataList.count == 0){    // 数据加载完成
            isLoadFinised = true;
        }else if(dataList.count >0){
            
            NSRange range = NSMakeRange([_listArray count],dataList.count);
            NSIndexSet *indexesToInsert = [[NSIndexSet alloc] initWithIndexesInRange:range];
            [_listArray addObjectsFromArray:dataList];
            
            // update the page scroller
            HGPageScrollView *pageScrollView = (HGPageScrollView *)[self.view viewWithTag:ScrollView_Tag];
            [pageScrollView insertPagesAtIndexes:indexesToInsert animated:YES];
            
            if(dataList.count < TopicList_Page_Size){
                isLoadFinised = true;
            }
        }
    } failure:^(NSString *errorStr) {
        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
    }];
}


#pragma mark -
#pragma mark HGPageScrollViewDataSource


- (NSInteger)numberOfPagesInScrollView:(HGPageScrollView *)scrollView;   // Default is 0 if not implemented
{
	return [_listArray count];
}


- (HGPageView *)pageScrollView:(HGPageScrollView *)scrollView viewForPageAtIndex:(NSInteger)index;
{
    static NSString *pageId = @"pageId";
    JDOTopicCell *topicCell = (JDOTopicCell *)[scrollView dequeueReusablePageWithIdentifier:pageId];
    if(!topicCell) {
        topicCell = [[JDOTopicCell alloc] initWithFrame:CGRectMake(0, 0, 320, 420)]; // 290*384
        topicCell.reuseIdentifier = pageId;
    }
    
    if(self.listArray.count > 0){
        JDOTopicModel *topicModel = (JDOTopicModel *)[_listArray objectAtIndex:index];
        [topicCell setModel:topicModel];
    }
    
    if (index == _listArray.count-1 && !isLoadFinised ){  // 到目前的最后一条后自动加载更多
        [self loadMore];
    }
    return topicCell;
	
}


#pragma mark -
#pragma mark HGPageScrollViewDelegate

- (void) pageScrollView:(HGPageScrollView *)scrollView didSelectPageAtIndex:(NSInteger)index
{
    [SharedAppDelegate deckController].enabled = false;
    
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)[SharedAppDelegate deckController].centerController;
    JDOTopicDetailController *detailController = [[JDOTopicDetailController alloc] initWithTopicModel:[self.listArray objectAtIndex:index] pController:self];
    [centerViewController pushViewController:detailController animated:true];
    
}


- (void)pageScrollView:(HGPageScrollView *)scrollView didDeselectPageAtIndex:(NSInteger)index
{
    [SharedAppDelegate deckController].enabled = true;
    
}



#pragma mark - toolbar Actions


- (void) returnFromDetail
{
	HGPageScrollView *pageScrollView = (HGPageScrollView *)[self.view viewWithTag:ScrollView_Tag];
	[pageScrollView deselectPageAnimated:YES];
}

@end

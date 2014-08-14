//
//  JDOReportPhotoList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-8-1.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOReportPhotoList.h"

#import "JDOReportListModel.h"
#import "JDOReportPhotoCell.h"
#import "SVPullToRefresh.h"
#import "JDOQuestionDetailController.h"
#import "JDOCenterViewController.h"
#import "DCParserConfiguration.h"
#import "DCArrayMapping.h"
#import "JDOArrayModel.h"

#define Finished_Label_Tag 111
#define Page_Size 10

@interface JDOReportPhotoList ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;
@property (strong,nonatomic) UIImageView *noDataView;
@property (strong,nonatomic) UIButton *publishBtn;

@end

@implementation JDOReportPhotoList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super init])) {
        self.frame = frame;
        self.currentPage = 1;
        self.listArray = [[NSMutableArray alloc] initWithCapacity:Page_Size];
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
        self.reuseIdentifier = reuseIdentifier;
        
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
        layout.headerHeight = 0;
        layout.footerHeight = 0;
        layout.minimumColumnSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.columnCount = 3;
        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
        
        _collectionView = [[PSUICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor colorWithHex:@"dcdcdc"];
        [_collectionView registerClass:[JDOReportPhotoCell class] forCellWithReuseIdentifier:@"ReportPhotoCell"];
        [self addSubview:_collectionView];
        
        __block JDOReportPhotoList *blockSelf = self;
        [self.collectionView addPullToRefreshWithActionHandler:^{
            [blockSelf refresh];
        }];
        [self.collectionView addInfiniteScrollingWithActionHandler:^{
            [blockSelf loadMore];
        }];
        
        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
        self.statusView.delegate = self;
        [self addSubview:self.statusView];
        
        // 爆料按钮
        self.publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.publishBtn.frame = CGRectMake((320-53)/2, CGRectGetHeight(self.bounds)-53-20, 53, 53);
        [self.publishBtn setImage:[UIImage imageNamed:@"report_publish"] forState:UIControlStateNormal];
        [self.publishBtn addTarget:self action:@selector(onPublish:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.publishBtn];
        
        // 无数据提示
        _noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_no_data"]];
        _noDataView.frame = CGRectMake(0, -44, 320, self.bounds.size.height);
        _noDataView.hidden = true;
        [self addSubview:_noDataView];
        
    }
    return self;
}

- (void)onPublish:(UIButton *)btn{
    NSLog(@"跳转到发布页");
}


- (void)dealloc{
    
}

- (void) setCurrentState:(ViewStatusType)status{
    self.status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.collectionView.hidden = false;
        self.publishBtn.hidden = false;
    }else{
        self.collectionView.hidden = true;
        self.publishBtn.hidden = true;
    }
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (NSDictionary *) listParam{
    NSMutableDictionary *listParam = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:self.currentPage],@"p",@Page_Size,@"pageSize",nil];
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
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOReportListModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_DETAIL_SERVICE modelClass:@"JDOArrayModel" config:config params:@{@"aid":@"28054"} success:^(JDOArrayModel *dataModel) {
        NSArray *dataList = (NSArray *)dataModel.data;
        [self setCurrentState:ViewStatusNormal];
        if(dataList == nil || dataList.count == 0){
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
        [self.collectionView.pullToRefreshView stopAnimating];
        return ;
    }
    
    self.currentPage = 1;
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOReportListModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_DETAIL_SERVICE modelClass:@"JDOArrayModel" config:config params:@{@"aid":@"28054"} success:^(JDOArrayModel *dataModel) {
        NSArray *dataList = dataModel.data;
        [self.collectionView.pullToRefreshView stopAnimating];
        if(dataList == nil || dataList.count == 0){
            self.noDataView.hidden = false;
        }else{
            self.noDataView.hidden = true;
        }
        [self dataLoadFinished:dataList];
    } failure:^(NSString *errorStr) {
        [self.collectionView.pullToRefreshView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"image"]) {
        dispatch_async(dispatch_get_main_queue(), ^{ // 若不在main queue中执行，则从缓存读取图片的时候不能正确更新布局
            // 更新每个单元格的大小以重新布局
            [self.collectionView.collectionViewLayout invalidateLayout];
        });
    }
}

- (void) dataLoadFinished:(NSArray *)dataList{
    // 移除所有的KVO观察者
    [self.listArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JDOReportListModel *model = (JDOReportListModel *)obj;
        [model removeObserver:self forKeyPath:@"image" context:nil];
    }];
    for (int i=0; i<dataList.count; i++) {
        JDOReportListModel *model = (JDOReportListModel *)dataList[i];
        [model addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self.listArray removeAllObjects];
    [self.listArray addObjectsFromArray:dataList];
    [self.collectionView reloadData];
    [self updateLastRefreshTime];
    
    //    if( dataList.count<Page_Size ){
    //        [self.collectionView.infiniteScrollingView setEnabled:false];
    //        [self.collectionView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
    //    }else{
    [self.collectionView.infiniteScrollingView setEnabled:true];
    [self.collectionView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = true;
    //    }
}

- (void) updateLastRefreshTime{
    self.lastUpdateTime = [NSDate date];
    NSString *updateTimeStr = [JDOCommonUtil formatDate:self.lastUpdateTime withFormatter:DateFormatYMDHM];
    [self.collectionView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
}

- (void) loadMore{
    if(![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        [self.collectionView.infiniteScrollingView stopAnimating];
        return ;
    }
    self.currentPage += 1;
    NSString *aid = self.currentPage%2==0?@"29864":@"32954";
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[JDOReportListModel class] forAttribute:@"data" onClass:[JDOArrayModel class]];
    [config addArrayMapper:mapper];
    [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_DETAIL_SERVICE modelClass:@"JDOArrayModel" config:config params:@{@"aid":aid} success:^(JDOArrayModel *dataModel) {
        NSArray *dataList = dataModel.data;
        [self.collectionView.infiniteScrollingView stopAnimating];
        bool finished = false;
        if(dataList == nil || dataList.count == 0){    // 数据加载完成
            finished = true;
        }else{
            int oldCount = self.listArray.count;
            for (int i=0; i<dataList.count; i++) {
                JDOReportListModel *model = (JDOReportListModel *)dataList[i];
                [model addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
            }
            [self.listArray addObjectsFromArray:dataList];
            [self.collectionView performBatchUpdates:^{
                for(int i=0;i<dataList.count;i++){
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:oldCount+i inSection:0]]];
                }
            } completion:nil];
            
            //            if(dataList.count < Page_Size){
            //                finished = true;
            //            }
        }
        if(finished){
            // 延时执行是为了给insertRowsAtIndexPaths的动画留出时间
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if([self.collectionView.infiniteScrollingView viewWithTag:Finished_Label_Tag]){
                    [self.collectionView.infiniteScrollingView viewWithTag:Finished_Label_Tag].hidden = false;
                }else{
                    UILabel *finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.infiniteScrollingView.bounds.size.width, self.collectionView.infiniteScrollingView.bounds.size.height)];
                    finishLabel.textAlignment = NSTextAlignmentCenter;
                    finishLabel.text = All_Data_Load_Finished;
                    finishLabel.tag = Finished_Label_Tag;
                    finishLabel.backgroundColor = [UIColor clearColor];
                    [self.collectionView.infiniteScrollingView setEnabled:false];
                    [self.collectionView.infiniteScrollingView addSubview:finishLabel];
                }
            });
        }
    } failure:^(NSString *errorStr) {
        [self.collectionView.infiniteScrollingView stopAnimating];
        [JDOCommonUtil showHintHUD:errorStr inView:self];
    }];
}

- (NSInteger)collectionView:(PSUICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView {
    return 1;
}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JDOReportPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReportPhotoCell" forIndexPath:indexPath];
    JDOReportListModel *model = (JDOReportListModel *)self.listArray[indexPath.item];
    cell.imageView.image = nil;
    [cell setModel:model];
    return cell;
}

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    JDOReportListModel *model = (JDOReportListModel *)self.listArray[indexPath.item];
    // 在这里若不计算真实item尺寸，则增加的40高度在缩放后无法计算
    CGFloat itemWidth = [(CHTCollectionViewWaterfallLayout *)collectionViewLayout itemWidthInSectionAtIndex:0];
    if (model.image){
        return CGSizeMake(itemWidth,itemWidth*model.image.size.height/model.image.size.width+55);
    }else if (model.width>0 && model.height>0) {
        return CGSizeMake(itemWidth,itemWidth*model.height/model.width+55);
    }
    return CGSizeMake(100, 100);
}
@end

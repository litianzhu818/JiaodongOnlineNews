//
//  JDOLivehoodDeptList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodDeptList.h"

#define Section_Height 43.0f
#define Line_Height 43.0f

#define List_Background @"livehood_content_background"
#define List_Background_Selected @"livehood_content_background_selected"

@interface JDOLivehoodDeptList()

@property (nonatomic,strong) NSArray *sectionTitleArray;
@property (nonatomic,strong) NSMutableArray *sectionContentArray;
@property (nonatomic,strong) NSMutableArray *headerViewArray;
@property (nonatomic,strong) NSMutableArray *sectionExpandState;

@end

@implementation JDOLivehoodDeptList{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
    int _selectedSection;
    int _currentSection;
}

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info {
    if ((self = [super init])) {
        self.frame = frame;
        self.info = info;
        _selectedSection = -1;
        
        self.reuseIdentifier = [info valueForKey:@"reuseId"];
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = Line_Height;
        [self addSubview:self.tableView];
        
        _sectionTitleArray = @[@"全部", @"A,C,D,F", @"G", @"H,J,K", @"L,M,N", @"Q,R,S,T", @"W,X", @"Y,Z", @"金融"];
        _sectionContentArray = [[NSMutableArray alloc] initWithCapacity:_sectionTitleArray.count];
        _headerViewArray = [[NSMutableArray alloc] initWithCapacity:_sectionTitleArray.count];
        _sectionExpandState = [[NSMutableArray alloc] initWithCapacity:_sectionTitleArray.count];
        
        for(int i=0;i<_sectionTitleArray.count;i++){
            NSMutableArray *contentArray = [[NSMutableArray alloc] init];
            [_sectionContentArray addObject:contentArray];
            
            UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            headerView.userInteractionEnabled = true;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSection:)];
            [headerView addGestureRecognizer:tapGesture];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
            label.backgroundColor = [UIColor clearColor];
            label.text = [_sectionTitleArray objectAtIndex:i];
            [headerView addSubview:label];
            [_headerViewArray addObject:headerView];
            
            [_sectionExpandState addObject:[NSNumber numberWithBool:false]];
        }
        
    }
    return self;
}

- (void)dealloc {
    for(int i=0;i<_headerViewArray.count;i++){
        UIImageView *iv = [_headerViewArray objectAtIndex:i];
        for(UIGestureRecognizer *gesture in iv.gestureRecognizers){
            [iv removeGestureRecognizer:gesture];
        }
    }
}

- (void) clickSection:(UITapGestureRecognizer *)tapGesture{
    UIImageView *headerView = (UIImageView *)tapGesture.view;
    _currentSection = [_headerViewArray indexOfObject:headerView];
    if( _selectedSection != _currentSection ){
        headerView.image = [UIImage imageNamed:@"livehood_content_background_selected"];
        
        if(index == 0){ // 全部部门
            // 转到相关问题
        }else{
            // 暂时禁用section部分的手势,防止快速连续点击造成_currentSection混乱
            [self setHeadViewGestureEnable:false];
            // 展开选中的section
            [self expandSection];
        }
    }else{
        [self setHeadViewGestureEnable:false];
        // 收缩或展开点击的section
        BOOL isExpand = [(NSNumber *)[_sectionExpandState objectAtIndex:_selectedSection] boolValue];
        if(isExpand){
            [[_sectionContentArray objectAtIndex:_selectedSection] removeAllObjects];
            [self.tableView reloadData];
        }else{
            [self expandSection];
        }
        [_sectionExpandState replaceObjectAtIndex:_selectedSection withObject:[NSNumber numberWithBool:!isExpand]];
        [self setHeadViewGestureEnable:true];
    }
}

- (void) setHeadViewGestureEnable:(BOOL) enable{
    for(int i=0;i<_headerViewArray.count;i++){
        [(UIView *)[_headerViewArray objectAtIndex:i] setUserInteractionEnabled:enable];
    }
}

- (void) expandSection{
    
    // 从本地缓存读取部门列表
    NSArray *deptList = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath( [@"LivehoodDeptCache" stringByAppendingFormat:@"%d",_currentSection] )];
    //本地json缓存不存在
    if( deptList == nil){
        // 从网络获取,并写入json缓存文件,记录上次更新时间
        [self loadDataFromNetwork];
    }else{
        NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:Dept_Update_Time] mutableCopy];
        NSString *sectionKey = [NSString stringWithFormat:@"DeptSection%d",_currentSection];
        if( updateTimes && [updateTimes objectForKey:sectionKey]){
            double lastUpdateTime = [(NSNumber *)[updateTimes objectForKey:sectionKey] doubleValue];
            // 上次加载时间离现在超过时间间隔
            if( [[NSDate date] timeIntervalSince1970] - lastUpdateTime > Dept_Update_Interval/**/ ){
                [self loadDataFromNetwork];
            }else{  // 使用缓存deptList
                [self refreshTable:deptList];
            }
        }else{  // 没有该section的上次刷新时间,正常不会进入该分支,因为既然存在缓存文件就应该记录过刷新时间,除非被删除过
            [self loadDataFromNetwork];
        }
    }
}

- (void) recordLastUpdateSuccessTime{
    NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:Dept_Update_Time] mutableCopy];
    if( updateTimes == nil){
        updateTimes = [[NSMutableDictionary alloc] initWithCapacity:_sectionTitleArray.count];
    }
    [updateTimes setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:[NSString stringWithFormat:@"DeptSection%d",_currentSection]];
    [[NSUserDefaults standardUserDefaults] setObject:updateTimes forKey:Dept_Update_Time];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadDataFromNetwork{
    NSString *deptKey = [_sectionTitleArray objectAtIndex:_currentSection];

    HUD = [[MBProgressHUD alloc] initWithView:SharedAppDelegate.window];
    [SharedAppDelegate.window addSubview:HUD];
//    HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
//    HUD.minShowTime = Hint_Min_Show_Time;
//    HUD.dimBackground = true;
    HUD.labelText = @"更新数据";
    HUD.removeFromSuperViewOnHide = true;
    [HUD show:true];
    HUDShowTime = [NSDate date];
    
    NSDictionary *param = @{@"letter":deptKey};
    // 加载列表
    [[JDOJsonClient sharedClient] getJSONByServiceName:BRANCHS_LIST_SERVICE modelClass:nil params:param success:^(NSArray *dataList) {
        if(dataList.count >0){  /* NSDictionary : dept_code,dept_name */
            [self recordLastUpdateSuccessTime];
            [NSKeyedArchiver archiveRootObject:dataList toFile:JDOGetCacheFilePath( [@"LivehoodDeptCache" stringByAppendingFormat:@"%d",_currentSection] )];
            if(HUD && HUDShowTime){
                // 防止加载提示消失的太快
                double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
                if(delay < Hint_Min_Show_Time){
                    usleep((Hint_Min_Show_Time-delay)*1000*1000);
                }
                [HUD hide:true];
                HUDShowTime = nil;
            }
            // HUD消失后再动画更新表格
            [self refreshTable:dataList];
        }
    } failure:^(NSString *errorStr) {
        [self dismissHUDOnLoadFailed:errorStr];
    }];
}

- (void) refreshTable:(NSArray *) dataList{
//    [self.tableView beginUpdates];
    if(_selectedSection != -1){
        UIImageView *lastSelectedView = (UIImageView *)[_headerViewArray objectAtIndex:_selectedSection];
        lastSelectedView.image = [UIImage imageNamed:@"livehood_content_background"];
        
        // 收缩原来的section
        if(_selectedSection > 0){
//            NSMutableArray *indexPaths = [NSMutableArray array];
//            int length = [[_sectionContentArray objectAtIndex:_selectedSection] count];
//            for(int i=0; i<length; i++){
//                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:_selectedSection]];
//            }
//            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [[_sectionContentArray objectAtIndex:_selectedSection] removeAllObjects];
        }
        
    }
    // 展开点击的section
    [[_sectionContentArray objectAtIndex:_currentSection] removeAllObjects];
    [[_sectionContentArray objectAtIndex:_currentSection] addObjectsFromArray:dataList];
//    NSMutableArray *indexPaths = [NSMutableArray array];
//    int length = [[_sectionContentArray objectAtIndex:_currentSection] count];
//    for(int i=0; i<length; i++){
//        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:_currentSection]];
//    }
//    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
//    [self.tableView endUpdates];
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_currentSection ] atScrollPosition:UITableViewScrollPositionTop animated:true];
    
    _selectedSection = _currentSection;
    
    [self setHeadViewGestureEnable:true];
}

- (void)dismissHUDOnLoadFailed:(NSString *)errorStr{
    if(HUD && HUDShowTime){
        // 防止加载提示消失的太快
        double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
        if(delay < Hint_Min_Show_Time){
            usleep(Hint_Min_Show_Time-delay*1000*1000);
        }
#warning 替换服务器错误的提示内容和图片
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = errorStr;
        [HUD hide:true afterDelay:1.0];
        HUDShowTime = nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Section_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIImageView *headerView = [_headerViewArray objectAtIndex:section];

    if(_selectedSection == section){
        headerView.image = [UIImage imageNamed:@"livehood_content_background_selected"];
    }else{
        headerView.image = [UIImage imageNamed:@"livehood_content_background"];
    }
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _sectionTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *contentArray = [_sectionContentArray objectAtIndex:section];
    return contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Dept_Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil){
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"livehood_item_background"]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSArray *deptArray = [_sectionContentArray objectAtIndex:indexPath.section];
    /* NSDictionary : dept_code,dept_name */
    NSDictionary *dept = (NSDictionary *)[deptArray objectAtIndex:indexPath.row];    
    cell.textLabel.text = [dept objectForKey:@"dept_name"];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Line_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        // section0 由于存在scrollView与didSelectRowAtIndexPath冲突，不会进入该函数，通过给UIImageView设置gesture的方式解决
    }else{
//        JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:[self.listArray objectAtIndex:indexPath.row]];
//        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
//        [centerController pushViewController:detailController animated:true];
//        [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
}


@end

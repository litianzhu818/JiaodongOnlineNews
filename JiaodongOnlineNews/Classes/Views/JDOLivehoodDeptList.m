//
//  JDOLivehoodDeptList.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodDeptList.h"
#import "JDOLivehoodViewController.h"

#define Section_Height 38.0f
#define Line_Height 35.0f
#define Section_Label_Tag 111
#define Section_Normal_Color [UIColor colorWithHex:@"505050"]
#define Section_Highlight_Color [UIColor whiteColor]
#define Shadow_Normal_Color [UIColor whiteColor]
#define Shadow_Highlight_Color [UIColor colorWithHex:@"505050"]

#define List_Background @"livehood_content_background"
#define List_Background_Selected @"livehood_content_background_selected"

#define Animation_Delay 0.35

@interface JDOLivehoodDeptList()

@property (nonatomic,strong) NSArray *sectionTitleArray;
@property (nonatomic,strong) NSMutableArray *sectionContentArray;
@property (nonatomic,strong) NSMutableArray *headerViewArray;
@property (nonatomic,strong) NSMutableArray *sectionExpandState;
@property (nonatomic,strong) NSArray *currentSectionList;
@property (nonatomic,strong) NSIndexPath *checkedIndexPath;

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
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHex:@"e8e8e8"];
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
            
            UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, Section_Height)];
            headerView.userInteractionEnabled = true;
            headerView.image = [UIImage imageNamed:@"livehood_content_background"];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSection:)];
            [headerView addGestureRecognizer:tapGesture];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, Section_Height)];
            label.textColor = Section_Normal_Color;
            label.shadowColor = Shadow_Normal_Color;
            label.shadowOffset = CGSizeMake(0, 1);
            label.backgroundColor = [UIColor clearColor];
            label.text = [_sectionTitleArray objectAtIndex:i];
            label.font = [UIFont systemFontOfSize:18];
            label.tag = Section_Label_Tag;
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
        
        if(_currentSection == 0){ // 全部部门
            // 转到相关问题
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeptChangedNotification object:nil userInfo:@{@"dept_code":@"ALL"}];
            [self.livehoodController.scrollView moveToNextAnimated:true];
        }else{
            [self loadSection];
        }
    }else{
        // 收缩或展开点击的section
        BOOL isExpand = [(NSNumber *)[_sectionExpandState objectAtIndex:_selectedSection] boolValue];
        if(isExpand){
            [self shrinkLastSection];
            _selectedSection = -1;
        }else{
            [self expandCurrentSection];
            _selectedSection = _currentSection;
        }
    }
}

// 暂时禁用section部分的手势,防止快速连续点击造成_currentSection混乱
- (void) setHeadViewGestureEnable:(BOOL) enable{
    for(int i=0;i<_headerViewArray.count;i++){
        [(UIView *)[_headerViewArray objectAtIndex:i] setUserInteractionEnabled:enable];
    }
}

- (void) loadSection{
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
                _currentSectionList = deptList;
                [self refreshTable];
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
    // 检查网络可用性
    if( ![Reachability isEnableNetwork]){ 
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        return;
    }
    NSString *deptKey = [_sectionTitleArray objectAtIndex:_currentSection];

    HUD = [[MBProgressHUD alloc] initWithView:SharedAppDelegate.window];
    [SharedAppDelegate.window addSubview:HUD];
    HUD.labelText = @"更新数据";
    HUD.removeFromSuperViewOnHide = true;
    [HUD show:true];
    HUDShowTime = [NSDate date];
    
    if([deptKey isEqualToString:@"金融"]){
        deptKey = @"B";
    }
    NSDictionary *param = @{@"letter":deptKey};
    // 加载列表
    [[JDOJsonClient sharedClient] getJSONByServiceName:BRANCHS_LIST_SERVICE modelClass:nil params:param success:^(NSArray *dataList) {
        if( dataList == nil || dataList.count == 0){  /* NSDictionary : dept_code,dept_name */
            [self dismissHUDOnLoadFailed:@"没有部门"];
        }else{
            [self recordLastUpdateSuccessTime];
            [NSKeyedArchiver archiveRootObject:dataList toFile:JDOGetCacheFilePath( [@"LivehoodDeptCache" stringByAppendingFormat:@"%d",_currentSection] )];
            if(HUD && HUDShowTime){
                [self delayHUD];
                [HUD hide:true];
                HUDShowTime = nil;
            }
            // HUD消失后再动画更新表格
            _currentSectionList = dataList;
            [self refreshTable];
        }
    } failure:^(NSString *errorStr) {
        [self dismissHUDOnLoadFailed:errorStr];
    }];
}

- (void) delayHUD {
    // 防止加载提示消失的太快
    double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
    if(delay < Hint_Min_Show_Time){
        usleep((Hint_Min_Show_Time-delay)*1000*1000);
    }
}

- (void) refreshTable {
    [self shrinkLastSection];
    if(_selectedSection == -1){
        [self expandCurrentSection];
    }else{
        [self performSelector:@selector(expandCurrentSection) withObject:nil afterDelay:Animation_Delay];
    }
    _selectedSection = _currentSection;
}

- (void) scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_currentSection ] atScrollPosition:UITableViewScrollPositionTop animated:true];
}

// 收缩原来的section
- (void) shrinkLastSection {
    if(_selectedSection != -1){
        UIImageView *lastSelectedView = (UIImageView *)[_headerViewArray objectAtIndex:_selectedSection];
        lastSelectedView.image = [UIImage imageNamed:@"livehood_content_background"];
        [(UILabel *)[lastSelectedView viewWithTag:Section_Label_Tag] setTextColor:Section_Normal_Color];
        [(UILabel *)[lastSelectedView viewWithTag:Section_Label_Tag] setShadowColor:Shadow_Normal_Color];
        
        [_sectionExpandState replaceObjectAtIndex:_selectedSection withObject:[NSNumber numberWithBool:false]];
        if(_selectedSection > 0){
            int length = [[_sectionContentArray objectAtIndex:_selectedSection] count];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for(int i=0; i<length; i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:_selectedSection]];
            }
            [[_sectionContentArray objectAtIndex:_selectedSection] removeAllObjects];

            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            // 不reloadSection会造成setion短暂空白
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:_selectedSection] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

// 展开点击的section
- (void) expandCurrentSection {
    UIImageView *headerView = (UIImageView *)[_headerViewArray objectAtIndex:_currentSection];
    headerView.image = [UIImage imageNamed:@"livehood_content_background_selected"];
    [(UILabel *)[headerView viewWithTag:Section_Label_Tag] setTextColor:Section_Highlight_Color];
    [(UILabel *)[headerView viewWithTag:Section_Label_Tag] setShadowColor:Shadow_Highlight_Color];
    
    [_sectionExpandState replaceObjectAtIndex:_currentSection withObject:[NSNumber numberWithBool:true]];
    [[_sectionContentArray objectAtIndex:_currentSection] addObjectsFromArray:_currentSectionList];
    
    int length = [[_sectionContentArray objectAtIndex:_currentSection] count];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for(int i=0; i<length; i++){
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:_currentSection]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    // 不reloadSection会造成setion短暂空白
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:_currentSection] withRowAnimation:UITableViewRowAnimationNone];
    
    [self performSelector:@selector(scrollToTop) withObject:nil afterDelay:Animation_Delay];
}

- (void)dismissHUDOnLoadFailed:(NSString *)errorStr{
    if(HUD && HUDShowTime){
        [self delayHUD];
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

//    if(_selectedSection == section){
//        headerView.image = [UIImage imageNamed:@"livehood_content_background_selected"];
//    }else{
//        headerView.image = [UIImage imageNamed:@"livehood_content_background"];
//    }
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
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor colorWithHex:@"808080"];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"livehood_item_background"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSArray *deptArray = [_sectionContentArray objectAtIndex:indexPath.section];
    /* NSDictionary : dept_code,dept_name */
    NSDictionary *dept = (NSDictionary *)[deptArray objectAtIndex:indexPath.row];    
    cell.textLabel.text = [dept objectForKey:@"dept_name"];
    // 当前选中部门打钩
    if( _checkedIndexPath != nil && _checkedIndexPath.row == indexPath.row && _checkedIndexPath.section == indexPath.section){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Line_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(_checkedIndexPath == nil || _checkedIndexPath.row != indexPath.row || _checkedIndexPath.section != indexPath.section ){
        if( _checkedIndexPath != nil ) {
            [tableView cellForRowAtIndexPath:self.checkedIndexPath].accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        
        NSArray *deptArray = [_sectionContentArray objectAtIndex:indexPath.section];
        /* NSDictionary : dept_code,dept_name */
        NSDictionary *dept = (NSDictionary *)[deptArray objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeptChangedNotification object:nil userInfo:@{@"dept_code":[dept objectForKey:@"dept_code"]}];
    }
    
    [self.livehoodController.scrollView moveToNextAnimated:true];
}


@end

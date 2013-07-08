//
//  JDOLivehoodAskQuestion.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodAskQuestion.h"

@implementation JDOLivehoodAskQuestion

- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info {
    if ((self = [super init])) {
//        self.frame = frame;
//        self.info = info;
//        self.currentPage = 1;
//        
//        self.reuseIdentifier = info.reuseId;
//        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
//        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
//        self.tableView.delegate = self;
//        self.tableView.dataSource = self;
//        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
//        self.tableView.rowHeight = News_Cell_Height;
//        [self addSubview:self.tableView];
//        
//        __block JDONewsCategoryView *blockSelf = self;
//        [self.tableView addPullToRefreshWithActionHandler:^{
//            [blockSelf refresh];
//        }];
//        [self.tableView addInfiniteScrollingWithActionHandler:^{
//            [blockSelf loadMore];
//        }];
//        
//        self.statusView = [[JDOStatusView alloc] initWithFrame:self.bounds];
//        [self addSubview:self.statusView];
//        
//        // 从本地缓存读取，本地缓存每个栏目只保存20条记录
//        BOOL hasCache = [self readListFromLocalCache];
//        //本地json缓存不存在
//        if( !hasCache){
//            self.headArray = [[NSMutableArray alloc] initWithCapacity:NewsHead_Page_Size];
//            self.listArray = [[NSMutableArray alloc] initWithCapacity:NewsList_Page_Size];
//            // 显示logo界面，不显示加载进度指示，当实际调用loadcurrentPage的时候才从网络加载并显示进度
//            [self setCurrentState:ViewStatusLogo];
//            _isShowingLocalCache = false;
//        }else{
//            [self setCurrentState:ViewStatusNormal];
//            _isShowingLocalCache = true;
//            // 上次刷新时间
//            NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:News_Update_Time] mutableCopy];
//            if( updateTimes != nil && [updateTimes objectForKey:self.info.title] ){
//                double updateTime = [(NSNumber *)[updateTimes objectForKey:self.info.title] doubleValue];
//                NSString *updateTimeStr = [JDOCommonUtil formatDate:[NSDate dateWithTimeIntervalSince1970:updateTime] withFormatter:DateFormatYMDHM];
//                [self.tableView.pullToRefreshView setSubtitle:[NSString stringWithFormat:@"上次刷新于:%@",updateTimeStr] forState:SVPullToRefreshStateAll];
//            }
//        }
    }
    return self;
}


@end

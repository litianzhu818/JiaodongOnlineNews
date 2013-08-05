//
//  JDOCollectView.h
//  
//
//  Created by 陈鹏 on 13-8-1.
//
//

#import "NIPageView.h"
@class JDOCollectDB;
@interface JDOCollectView : NIPageView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *noResultView;
@property (nonatomic,strong) JDOCollectDB *collectDB;
@property (nonatomic,strong) NSMutableArray *datas;
- (id)initWithFrame:(CGRect)frame collectDB:(JDOCollectDB *)collectDB;
-(void)loadData;
@end

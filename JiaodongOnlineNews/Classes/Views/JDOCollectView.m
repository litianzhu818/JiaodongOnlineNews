//
//  JDOCollectView.m
//  
//
//  Created by 陈鹏 on 13-8-1.
//
//

#import "JDOCollectView.h"
#import "JDOCollectDB.h"
@implementation JDOCollectView

- (id)initWithFrame:(CGRect)frame collectDB:(JDOCollectDB *)collectDB;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.collectDB = collectDB;
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
        self.tableView.rowHeight = News_Cell_Height;
        [self addSubview:self.tableView];
        
        self.noResultView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_no_data"]];
        self.noResultView.frame = self.bounds;
        self.noResultView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        self.noResultView.contentMode = UIViewContentModeScaleAspectFit;
        //        self.retryView.center = self.center;
        self.noResultView.userInteractionEnabled = true;
        [self addSubview:self.noResultView];
        self.datas = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(loadData) name:kCollectNotification object:nil];
        [self loadData];
    }
    return self;
}

-(void)loadData{
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count];
}
//继承该方法时,左右滑动会出现删除按钮(自定义按钮),点击按钮时的操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    id<JDOToolbarModel> model = [self.datas objectAtIndex:indexPath.row];
    [self.collectDB deleteById:[model id]];
    [self.datas removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    if([self.datas count] == 0){
        [self.tableView setHidden:TRUE];
        [self.noResultView setHidden:FALSE];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    return @"删除";
}
@end

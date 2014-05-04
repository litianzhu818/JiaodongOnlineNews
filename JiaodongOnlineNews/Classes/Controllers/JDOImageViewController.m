//
//  JDOImageViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageViewController.h"
#import "JDOImageModel.h"
#import "UIImageView+WebCache.h"
#import "JDOImageCell.h"
#import "JDOImageDetailController.h"

#define ImageList_Page_Size 10

@interface JDOImageViewController ()

@property (nonatomic,strong) NSDate *lastUpdateTime;
@property (nonatomic,assign) int currentPage;

@end

@implementation JDOImageViewController

#warning 图片与话题增加本地文件缓存,其实图片可以将逻辑放在父类的ListViewController中，通过参数设置是否缓存及状态的变化
-(id)init{
    self.myDelegate = (JDOAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@ImageList_Page_Size forKey:@"pageSize"];
    self = [super initWithServiceName:IMAGE_SERVICE modelClass:@"JDOImageModel" title:@"精选图片" params:params needRefreshControl:true];
    if(self){
        [self setIsCacheToMemory:TRUE andCacheFileName:@"ImageListCache"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.rowHeight = 200.0f;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.myDelegate.hasNewAction) {
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn_new"] forState:UIControlStateNormal];
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn_new"] forState:UIControlStateHighlighted];
    } else {
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn"] forState:UIControlStateNormal];
        [self.navigationView.leftBtn setImage:[UIImage imageNamed:@"left_menu_btn"] forState:UIControlStateHighlighted];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) setupNavigationView{
    [self.navigationView addLeftButtonImage:@"left_menu_btn" highlightImage:@"left_menu_btn" target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationView addRightButtonImage:@"right_menu_btn" highlightImage:@"right_menu_btn" target:self.viewDeckController action:@selector(toggleRightView)];
    [self.navigationView setTitle:@"精选图片"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count==0 ? 10:self.listArray.count;
}

// 加了空section，为了补齐上边距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 9;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 9)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseId = @"ImageCell";
    JDOImageCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if(cell == nil){
        cell = [[JDOImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
    }
    if(self.listArray.count > 0){
        JDOImageModel *imageModel = [self.listArray objectAtIndex:indexPath.row];
        [cell setModel:imageModel];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JDOImageDetailController *detailController = [[JDOImageDetailController alloc] initWithImageModel:[self.listArray objectAtIndex:indexPath.row]];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:detailController animated:true];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end

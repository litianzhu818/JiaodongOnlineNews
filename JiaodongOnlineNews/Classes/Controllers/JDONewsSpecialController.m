//
//  JDONewsSpecialViewController.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 14-1-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDONewsSpecialController.h"
#import "JDONewsDetailController.h"
#import "JDOImageModel.h"
#import "JDOTopicModel.h"
#import "JDOTopicDetailController.h"
#import "JDOImageDetailController.h"
#import "JDOPartyDetailController.h"
#import "JDOPartyModel.h"
#import "JDONewsTableCell.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"

#define Default_Image @"news_head_placeholder.png"

@interface JDONewsSpecialController ()
@property (nonatomic,assign) int currentPage;
@end

@implementation JDONewsSpecialController{
    MBProgressHUD *HUD;
    NSDate *HUDShowTime;
}

-(id)initWithModel:(JDONewsSpecialModel *)model{
    if(self = [super initWithNibName:nil bundle:nil]){
        self.model = model;
    }
    return self;
}


-(void)loadView{
    [super loadView];
    self.listArray = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
    //    //self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 分割线用背景图片实现
    self.tableView.rowHeight = News_Cell_Height;
    [self.view addSubview:self.tableView];
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
    self.statusView.delegate = self;
    [self.view addSubview:self.statusView];
    
    [self loadDataFromNetwork];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (void)setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(onBackBtnClick)];
    [self.navigationView setTitle:@"新闻专题"];
}
- (void) onBackBtnClick{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)SharedAppDelegate.deckController.centerController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void)loadDataFromNetwork{
    
    if(self.status != ViewStatusLoading){   // 已经是loading状态就不需要HUD了，在没有缓存数据的时候发生
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        //        HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
        //        HUD.minShowTime = Hint_Min_Show_Time;
        //        HUD.dimBackground = true;
        HUD.labelText = @"更新数据";
        HUD.margin = 15.f;
        HUD.removeFromSuperViewOnHide = true;
        [HUD show:true];
        HUDShowTime = [NSDate date];
        //        [HUD addObserver:self forKeyPath:@"frame" options:15 context:nil];
    }
    
//    [[JDOJsonClient sharedClient] getPath:NEWS_SPECIAL_SERVICE parameters:self.newsListParam  success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSArray class]]) {
//            [self setCurrentState:ViewStatusRetry];
//        }else if([responseObject isKindOfClass:[NSDictionary class]]){
//            NSArray *array = [responseObject objectForKey:@"data"];
//            DCKeyValueObjectMapping *mapper  = [DCKeyValueObjectMapping mapperForClass:NSClassFromString(@"JDONewsModel") andConfiguration:[DCParserConfiguration configuration]];
//            [self.listArray removeAllObjects];
//            [self.listArray addObjectsFromArray:[mapper parseArray:array]];
//            [self loadFinished];
//            [self dismissHUDOnLoadFinished];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self setCurrentState:ViewStatusRetry];
//    }];
    
//    // 加载列表
    [[JDOHttpClient sharedClient] getJSONByServiceName:NEWS_SPECIAL_SERVICE modelClass:@"JDONewsModel" params:self.newsListParam success:^(NSArray *dataList) {
        
        if(dataList != nil && dataList.count >0){
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:dataList];
            [self loadFinished];
            [self dismissHUDOnLoadFinished];
        }else {
#warning 暂时未考虑频道无数据的情况
        }
    } failure:^(NSString *errorStr) {
        [self handleLoadError:errorStr];
    }];
}
- (NSDictionary *) newsListParam{
    return @{@"aid":self.model.id};
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self setCurrentPage:ViewStatusLoading];
    self.listArray = [[NSMutableArray alloc] init];
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self setCurrentPage:ViewStatusLoading];
    self.listArray = [[NSMutableArray alloc] init];
    [self loadDataFromNetwork];
}

- (void) setCurrentState:(ViewStatusType)status{
    self.status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.tableView.hidden = false;
    }else{
        self.tableView.hidden = true;
    }
}

- (void) handleLoadError:(NSString *) errorStr{
    [self dismissHUDOnLoadFinished];
    if(self.status == ViewStatusLoading){
        [self setCurrentState:ViewStatusRetry];
    }else if(self.status == ViewStatusNormal){
        [self dismissHUDOnLoadFailed:errorStr];
        [self setCurrentState:ViewStatusRetry];
    }
}

- (void) loadFinished{
    [self reloadTableView];
}

- (void) reloadTableView{
    [self setCurrentState:ViewStatusNormal];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }else{
        return self.listArray.count==0 ? 20:self.listArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)  return Headline_Height;
    return News_Cell_Height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *topIdentifier = @"topIdentifier";
    static NSString *listIdentifier = @"listIdentifier1";
    
    if(indexPath.section == 0){
        UITableViewCell *topCell = [tableView dequeueReusableCellWithIdentifier:topIdentifier];
        if (topCell == nil) {
            topCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topIdentifier];
            UIImageView *topimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, Headline_Height)];
            //topimage.image = [UIImage imageNamed:Default_Image];
            [topimage setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:self.model.spic]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
                if(!cached){    // 非缓存加载时使用渐变动画
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionFade;
                    [topimage.layer addAnimation:transition forKey:nil];
                }
            } failure:^(NSError *error) {
                
            }];
            [topCell.contentView addSubview:topimage];
        }
        return topCell;
    }else{
        JDONewsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:listIdentifier];
        if (cell == nil){
            cell =[[JDONewsTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:listIdentifier];
        }
        if(self.listArray.count > 0){
            JDONewsModel *newsModel = [self.listArray objectAtIndex:indexPath.row];
            [cell setModel:newsModel];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        // section0 由于存在scrollView与didSelectRowAtIndexPath冲突，不会进入该函数，通过给UIImageView设置gesture的方式解决
    }else{
        JDONewsModel *newsmodel = [self.listArray objectAtIndex:indexPath.row];
        
        NSArray *types = [newsmodel.atype componentsSeparatedByString:@","];
        for (int i=0; i<[types count]; i++) {
            NSString *aType = [types objectAtIndex:i];
            if ([aType isEqualToString:@"g"]) { // 图集
                newsmodel.contentType = @"picture";
                break;
            } else if ([aType isEqualToString:@"t"]) {  // 话题
                newsmodel.contentType = @"topic";
                break;
            } else if ([aType isEqualToString:@"ac"]) { // 活动
                newsmodel.contentType = @"party";
                break;
            } else if ([aType isEqualToString:@"s"]) { // 专题
                newsmodel.contentType = @"special";
                break;
            }
        }
        
        if (newsmodel.contentType == nil) {
            JDONewsDetailController *detailController = [[JDONewsDetailController alloc] initWithNewsModel:newsmodel];
            [newsmodel setRead:TRUE];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:detailController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        } else if ([newsmodel.contentType isEqualToString:@"picture"]) {
            JDOImageModel *imageModel = [[JDOImageModel alloc] initWithNewsModel:newsmodel];
            [newsmodel setRead:TRUE];
            JDOImageDetailController *imageController = [[JDOImageDetailController alloc] initWithImageModel:imageModel];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:imageController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        } else if ([newsmodel.contentType isEqualToString:@"topic"]) {
            JDOTopicModel *topicModel = [[JDOTopicModel alloc] initWithNewsModel:newsmodel];
            [newsmodel setRead:TRUE];
            JDOTopicDetailController *topicController = [[JDOTopicDetailController alloc] initWithTopicModel:topicModel pController:nil];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:topicController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        } else if ([newsmodel.contentType isEqualToString:@"party"]) {
            JDOPartyModel *partyModel = [[JDOPartyModel alloc] initWithNewsModel:newsmodel];
            [newsmodel setRead:TRUE];
            JDOPartyDetailController *partyController = [[JDOPartyDetailController alloc] initWithPartyModel:partyModel];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:partyController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        } else if ([newsmodel.contentType isEqualToString:@"special"]) {
            JDONewsSpecialModel *specialModel = [[JDONewsSpecialModel alloc] init];
            specialModel.id = newsmodel.id;
            specialModel.spic = newsmodel.spic;
            JDONewsSpecialController *specialController = [[JDONewsSpecialController alloc] initWithModel:specialModel];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
            [centerController pushViewController:specialController animated:true];
            [tableView deselectRowAtIndexPath:indexPath animated:true];
        }
    }
}

- (void)dismissHUDOnLoadFinished{
    if(HUD && HUDShowTime){
        // 防止加载提示消失的太快
        double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
        if(delay < Hint_Min_Show_Time){
            usleep((Hint_Min_Show_Time-delay)*1000*1000);
        }
        [HUD hide:true];
        HUDShowTime = nil;
        HUD = nil;
    }
}

- (void)dismissHUDOnLoadFailed:(NSString *)errorStr{
    if(HUD && HUDShowTime){
        // 防止加载提示消失的太快
        double delay = [[NSDate date] timeIntervalSinceDate:HUDShowTime];
        if(delay < Hint_Min_Show_Time){
            usleep(Hint_Min_Show_Time-delay*1000*1000);
        }
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"status_icon_error"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = errorStr;
        [HUD hide:true afterDelay:1.0];
        HUDShowTime = nil;
        HUD = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

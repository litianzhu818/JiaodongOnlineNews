//
//  LeftViewController.m
//  ViewDeckExample
//


#import "JDOLeftViewController.h"
#import "IIViewDeckController.h"
#import "JDOCenterViewController.h"

#define Menu_Cell_Height 55.0f
#define Menu_Image_Tag 101
#define Left_Margin 40.0f
#define Top_Margin 7.5f
#define Padding 5.0f
//#define Weather_Icon_Height 56
//#define Weather_Icon_Width 180.0/130.0*56
#define Separator_Y 324.0

@interface JDOLeftViewController ()

@property (strong) UIView *blackMask;
@property (nonatomic,strong) NSMutableArray *controllerStack;

@end

@implementation JDOLeftViewController{
    NSArray *iconNames;
    NSArray *iconSelectedNames;
    //NSArray *iconTitles;
}

- (id)init{
    self = [super init];
    if (self) {
        self.myDelegate = (JDOAppDelegate *)[[UIApplication sharedApplication] delegate];
        _lastSelectedRow = 0;
        iconNames = @[@"menu_news",@"menu_party",@"menu_picture",@"menu_topic",@"menu_convenience",@"menu_livehood",@"menu_video",@"menu_report"];
        iconSelectedNames = @[@"menu_news_selected",@"menu_party_selected",@"menu_picture_selected",@"menu_topic_selected",@"menu_convenience_selected",@"menu_livehood_selected",@"menu_video_selected",@"menu_report_selected"];
        //iconTitles = @[@"胶东在线",@"精选图片",@"每日一题",@"便民查询",@"网上民声"];
        
        hasNewView = [[UIImageView alloc] initWithFrame:CGRectMake(155.0, 8.0, 26.0, 19.0)];
        [hasNewView setImage:[UIImage imageNamed:@"menu_party_hasnew"]];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height) ];
    backgroundView.image = [UIImage imageNamed:@"menu_background_left"];
    [self.view addSubview:backgroundView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Is_iOS7?20:0, 320, Menu_Cell_Height*MenuItemCount) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = Menu_Cell_Height;
    _tableView.scrollEnabled = false;
    [self.view addSubview:_tableView];
    
//    UIImageView *separateView = [[UIImageView alloc] initWithFrame:CGRectMake(0, Separator_Y, 320, 1)];
//    separateView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    separateView.image = [UIImage imageNamed:@"menu_separator.png"];
//    [self.view addSubview:separateView];
    
    _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackMask];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    IIViewDeckController *deckController = [SharedAppDelegate deckController];
    _controllerStack = [[NSMutableArray alloc] init];
    [_controllerStack addObject:deckController];
}

// 之前天气放在左菜单下面，为了打开天气详情增加的这两个方法，现在转移到右菜单中
//- (void) pushViewController:(JDONavigationController *)controller{
//    controller.stackViewController = self;
//    [((UIViewController *)[_controllerStack lastObject]).view pushView:controller.view startFrame:Transition_Window_Right endFrame:Transition_Window_Center complete:^{
//        
//    }];
//    [_controllerStack addObject:controller];
//}
//
//- (void) popViewController{
//    JDONavigationController *_lastController = [_controllerStack lastObject];
//    _lastController.stackViewController = nil;
//    [_controllerStack removeLastObject];
//    [_lastController.view popView:((UIViewController *)[_controllerStack lastObject]).view startFrame:Transition_Window_Center endFrame:Transition_Window_Right complete:^{
//        
//    }];
//}

- (void)viewWillAppear:(BOOL)animated{
    //    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
}

- (void) transitionToAlpha:(float) alpha Scale:(float) scale{
    self.blackMask.alpha = alpha;
    self.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.blackMask = nil;
    self.controllerStack = nil;
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MenuItemCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"MenuItem";
    
    UIImageView *imageView;
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        // 因为图片大小不一致,调整frame以对齐，"活动"往右一像素，"电视"往左一像素
        if (indexPath.row == MenuItemParty ) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin+1, 0, 115, Menu_Cell_Height)];
        }else if(indexPath.row == MenuItemVideo ) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin-1, 0, 115, Menu_Cell_Height)];
        }else{
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin, 0, 115, Menu_Cell_Height)];
        }
        [imageView setTag:Menu_Image_Tag];
        [cell.contentView addSubview:imageView];
        if (indexPath.row == 1) {
            [cell.contentView addSubview:hasNewView];
        }
        if (self.myDelegate.hasNewAction) {
            [hasNewView setHidden:NO];
        } else {
            [hasNewView setHidden:YES];
        }
    }
    
    imageView = (UIImageView *)[cell viewWithTag:Menu_Image_Tag];
    if(indexPath.row == _lastSelectedRow){
        imageView.image = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected"]];
        //        cell.textLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:169.0/255.0 blue:237.0/255.0 alpha:1.0];
    }else{
        imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:indexPath.row]];
        cell.backgroundView = nil;
        //        cell.textLabel.textColor = [UIColor whiteColor];
    }
    //    cell.textLabel.text = [iconTitles objectAtIndex:indexPath.row];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50.0;
//}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.row == _lastSelectedRow){
        [self.viewDeckController closeLeftViewAnimated:true];
        return ;
    }
//    UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
//    cell.imageView.image = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
//    if( lastSelectedRow != -1){
//        UITableViewCell *lastSelectedCell  = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedRow inSection:0]];
//        lastSelectedCell.imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:lastSelectedRow]];
//        lastSelectedCell.backgroundView = nil;
//    }
    if (indexPath.row == MenuItemParty) {
        if (self.myDelegate.hasNewAction) {
            self.myDelegate.hasNewAction = NO;
            [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"ServiceActionId"] forKey:@"LocalActionId"];
        }
        [hasNewView setHidden:YES];
    }
    _lastSelectedRow = indexPath.row;
    [tableView reloadData];
    
    // 使用slide动画关闭左菜单
//    if ([self.viewDeckController.centerController isKindOfClass:[JDOCenterViewController class]]) {
//        JDOCenterViewController *centerController = (JDOCenterViewController *)self.viewDeckController.centerController;
//        [centerController setRootViewControllerType:indexPath.row];
//    }
//    [self.viewDeckController closeLeftViewAnimated:true];
    
    // 使用Bouncing动画关闭左菜单
    [self.viewDeckController closeSideView:IIViewDeckLeftSide bounceOffset:320-self.viewDeckController.leftSize+30 bounced:^(IIViewDeckController *controller) {
        if ([self.viewDeckController.centerController isKindOfClass:[JDOCenterViewController class]]) {
            JDOCenterViewController *centerController = (JDOCenterViewController *)self.viewDeckController.centerController;
            [centerController setRootViewControllerType:indexPath.row];
        }
    } completion:^(IIViewDeckController *controller, BOOL success) {
        
    }];
    
}

@end

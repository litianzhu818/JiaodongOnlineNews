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
        _lastSelectedRow = 0;
        iconNames = @[@"menu_news",@"menu_picture",@"menu_topic",@"menu_convenience",@"menu_livehood",@"menu_party"];
        iconSelectedNames = @[@"menu_news_selected",@"menu_picture_selected",@"menu_topic_selected",@"menu_convenience_selected",@"menu_livehood_selected",@"menu_party_selected"];
        //iconTitles = @[@"胶东在线",@"精选图片",@"每日一题",@"便民查询",@"网上民声"];
        
    }
    return self;
}

- (void)loadView{
    [super loadView];
    // 先将height固定设置为iPhone4的高度480，在viewDidLoad时候再重新设置回App_Height，目的是为了通过autoresizingMask自动布局天气中的控件，因为只有bounds变化才能引起autoresize起作用
    self.view.bounds =CGRectMake(0, 0, 320, 460);
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height) ];
    backgroundView.image = [UIImage imageNamed:@"menu_background.png"];
    [self.view addSubview:backgroundView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, Menu_Cell_Height*MenuItemCount) style:UITableViewStylePlain];
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
    self.view.bounds = CGRectMake(0, 0, 320, App_Height);

}

- (void) pushViewController:(JDONavigationController *)controller{
    controller.stackViewController = self;
    [((UIViewController *)[_controllerStack lastObject]).view pushView:controller.view startFrame:Transition_Window_Right endFrame:Transition_Window_Center complete:^{
        
    }];
    [_controllerStack addObject:controller];
}

- (void) popViewController{
    JDONavigationController *_lastController = [_controllerStack lastObject];
    _lastController.stackViewController = nil;
    [_controllerStack removeLastObject];
    [_lastController.view popView:((UIViewController *)[_controllerStack lastObject]).view startFrame:Transition_Window_Center endFrame:Transition_Window_Right complete:^{
        
    }];
}

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
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin, 0, 115, Menu_Cell_Height)];
        [imageView setTag:Menu_Image_Tag];
        [cell.contentView addSubview:imageView];
    }
    
    imageView = (UIImageView *)[cell viewWithTag:Menu_Image_Tag];
    if(indexPath.row == _lastSelectedRow){
        imageView.image = [UIImage imageNamed:[iconSelectedNames objectAtIndex:indexPath.row]];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_row_selected.png"]];
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

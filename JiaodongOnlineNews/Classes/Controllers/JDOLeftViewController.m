//
//  LeftViewController.m
//  ViewDeckExample
//


#import "JDOLeftViewController.h"
#import "IIViewDeckController.h"
#import "JDOCenterViewController.h"

@interface JDOLeftViewController ()

@property (strong) UIView *blackMask;

@end

@implementation JDOLeftViewController

NSArray *iconNames;
NSArray *iconTitles;

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    iconNames = @[@"left_menu",@"left_menu",@"left_menu",@"left_menu",@"left_menu"];
    iconTitles = @[@"新闻",@"图片",@"话题",@"便民",@"民声"];
    
    self.tableView.scrollsToTop = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    _blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
    _blackMask.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackMask];
    
}

- (void) transitionToAlpha:(float) alpha Scale:(float) scale{
    self.blackMask.alpha = alpha;
//    self.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:indexPath.row]];
    cell.textLabel.text = [iconTitles objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        if ([controller.centerController isKindOfClass:[JDOCenterViewController class]]) {
            JDOCenterViewController *centerController = (JDOCenterViewController *)controller.centerController;
            [centerController setRootViewControllerType:indexPath.row];
        }
    } completion:^(IIViewDeckController *controller, BOOL success) {
        
    }];
}

@end

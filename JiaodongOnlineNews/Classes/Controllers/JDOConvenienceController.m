//
//  JDOConvenienceController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-6.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOConvenienceController.h"
#import "BadgedLauncherButtonView.h"
#import "JDOConvenienceViewModel.h"

@interface JDOConvenienceController () <NILauncherViewModelDelegate>
@property (nonatomic, readwrite, retain) JDOConvenienceViewModel* model;
@end

@implementation JDOConvenienceController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Badges";
        
        NSArray *icons = @[@"bus",@"transport",@"train",@"ship",@"breakrule",@"airplane",@"telnumber",@"lifeknowledge",@"ytweather"];
        NSArray *titles = @[@"公交班次",@"客运时刻",@"火车时刻",@"船运时刻",@"违章查询",@"航空时刻",@"常用电话",@"生活常识",@"烟台天气"];
        
        NSMutableArray* contents = [[NSMutableArray alloc] initWithCapacity:9];
        for( int i=0;i<9;i++){
            [contents addObject:[BadgedLauncherViewObject objectWithTitle:[titles objectAtIndex:i] image:[UIImage imageNamed:[icons objectAtIndex:i] ] badgeNumber:0]];
        }
        _model = [[JDOConvenienceViewModel alloc] initWithArrayOfPages:@[contents] delegate:self];
    }
    return self;
}

- (void)loadView {
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height)];
    self.launcherView = [[NILauncherView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
    self.launcherView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    
    [self.view addSubview:self.launcherView];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationView = [[JDONavigationView alloc] init];
    [self setupNavigationView];
    [self.view addSubview:_navigationView];
    
    self.launcherView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.launcherView.delegate = self;
    self.launcherView.dataSource = self.model;
    [self.launcherView setContentInsetForPages:UIEdgeInsetsMake(40,20,40,20)];
    [self.launcherView reloadData];
}

- (void)setupNavigationView{
    [_navigationView addBackButtonWithTarget:self.viewDeckController action:@selector(toggleLeftView)];
    [_navigationView addCustomButtonWithTarget:self.viewDeckController action:@selector(toggleRightView)];
    [_navigationView setTitle:@"便民查询"];
    
}

- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object {
    NILauncherButtonView* launcherButtonView = (NILauncherButtonView *)buttonView;
    launcherButtonView.label.layer.shadowColor = [UIColor blackColor].CGColor;
    launcherButtonView.label.layer.shadowOffset = CGSizeMake(0, 1);
    launcherButtonView.label.layer.shadowOpacity = 1;
    launcherButtonView.label.layer.shadowRadius = 1;
}

#pragma mark - NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index {
    id<NILauncherViewObject> object = [self.model objectAtIndex:index pageIndex:page];
    
    static JDOConvenienceItemController *controller = nil;
    controller = [[JDOConvenienceItemController alloc] initWithNibName:nil bundle:nil];

    switch (index) {
        case 0:
            controller.title = @"公交班次";
            controller.channelid = @"19";
            break;
        case 1:
            controller.title = @"客运时刻";
            controller.channelid = @"22";
            break;
        case 2:
            controller.title = @"火车时刻";
            controller.channelid = @"23";
            break;
        case 3:
            controller.title = @"船运时刻";
            controller.channelid = @"24";
            break;
        case 4:
            controller.title = @"违章查询";
            break;
        case 5:
            controller.title = @"航空时刻";
            controller.channelid = @"25";
            break;
        case 6:
            controller.title = @"常用电话";
            controller.channelid = @"26";
            break;
        case 7:
            controller.title = @"生活常识";
            controller.channelid = @"27";
            break;
        case 8:
            controller.title = @"烟台天气";
            controller.channelid = @"21";
            break;
    }
    [self.navigationController pushViewController:controller animated:YES];
    controller = nil;

}

@end

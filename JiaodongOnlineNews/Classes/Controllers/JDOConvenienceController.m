//
//  JDOConvenienceController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-6.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOConvenienceController.h"
#import "BadgedLauncherButtonView.h"
#import "JDOViolationViewController.h"
#import "JDOBusLIstViewController.h"
#import "JDOLifeKnowledgeViewController.h"

@interface JDOConvenienceController () <NILauncherViewModelDelegate>
@property (nonatomic, readwrite, retain) NILauncherViewModel* model;
@end

@implementation JDOConvenienceController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        NSArray *icons = @[@"bus",@"transport",@"train",@"ship",@"breakrule",@"airplane",@"telnumber",@"lifeknowledge",@"ytweather",@"",@"",@""];
        NSArray *titles = @[@"公交班次",@"客运时刻",@"火车时刻",@"船运时刻",@"违章查询",@"航空时刻",@"常用电话",@"生活常识",@"烟台天气",@"",@"",@""];
        
        NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:12];
        for( int i=0;i<12;i++){  // 暂时不包括天气
            [contents addObject:[BadgedLauncherViewObject objectWithTitle:[titles objectAtIndex:i] image:[UIImage imageNamed:[icons objectAtIndex:i] ] badgeNumber:0]];
        }
        _model = [[NILauncherViewModel alloc] initWithArrayOfPages:@[contents] delegate:self];
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
    
    self.launcherView.backgroundColor = [UIColor colorWithHex:Main_Background_Color]; // 236.0
    self.launcherView.delegate = self;
    self.launcherView.dataSource = self.model;
    if (App_Height > 480)
        self.launcherView.numberOfRows = 4;
    else
        self.launcherView.numberOfRows = 3;
    self.launcherView.numberOfColumns = 3;
//    16号字行高20(85行设置),buttonSize的高度包括Label的高度(图片尺寸75*90),为适应航班图片(112.5*52)增加宽度,但不能超过总宽度320,否则会换行,所以取最大值320/3
    self.launcherView.buttonSize = CGSizeMake(107, 110);
    [self.launcherView setContentInsetForPages:UIEdgeInsetsMake(10,0,30,0)];
    [self.launcherView reloadData];
}

- (void)setupNavigationView{
    [self.navigationView addLeftButtonImage:@"left_menu_btn" highlightImage:@"left_menu_btn" target:self.viewDeckController action:@selector(toggleLeftView)];
    [self.navigationView addRightButtonImage:@"right_menu_btn" highlightImage:@"right_menu_btn" target:self.viewDeckController action:@selector(toggleRightView)];
    [_navigationView setTitle:@"便民查询"];
}

- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object {
    NILauncherButtonView* launcherButtonView = (NILauncherButtonView *)buttonView;
    
    if (buttonIndex >= 8) {
        [buttonView setHidden:YES];
    }
    
    // 若不设置UIControlStateHighlighted状态，点击后图片会被缩放
    [launcherButtonView.button setImage:object.image forState:UIControlStateHighlighted];
    [launcherButtonView.button setBackgroundImage:[UIImage imageNamed:@"navigation_button_clicked"] forState:UIControlStateHighlighted];
    
    // UIButton的image默认有padding,backgroundImage没有
    launcherButtonView.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    launcherButtonView.button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    // 在NILauncherButtonView被设置为UIViewContentModeCenter:image不会被缩放到和imageView相同大小
    launcherButtonView.button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    launcherButtonView.label.font = [UIFont boldSystemFontOfSize:16];
    launcherButtonView.label.textColor = [UIColor colorWithHex:Black_Color_Type1];
    // bounds = 0 ,曲线路径无效
//    launcherButtonView.label.layer.shadowPath = [UIBezierPath bezierPathWithRect:launcherButtonView.label.bounds].CGPath;
//    launcherButtonView.label.layer.shadowColor = [UIColor blackColor].CGColor;
//    launcherButtonView.label.layer.shadowOffset = CGSizeMake(0, 1);
//    launcherButtonView.label.layer.shadowOpacity = 1;
//    launcherButtonView.label.layer.shadowRadius = 1;
}

#pragma mark - NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index {
//    id<NILauncherViewObject> object = [self.model objectAtIndex:index pageIndex:page];
    
    if (index == 4){
        JDOViolationViewController *violation = [[JDOViolationViewController alloc] initwithStatus:NO];
        [self.navigationController pushViewController:violation animated:YES];
    } else if (index == 0){
        JDOBusLIstViewController *buslist = [[JDOBusLIstViewController alloc] init];
        [self.navigationController pushViewController:buslist animated:YES];
    } else if (index == 7){
        JDOLifeKnowledgeViewController *lifeknowledge = [[JDOLifeKnowledgeViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:lifeknowledge animated:YES];
    } else {
        NSString *title ,*channelId;
        BOOL deletetitle;
        
        switch (index) {
            case 1:
                title = @"客运时刻";
                channelId = @"22";
                deletetitle = YES;
                break;
            case 2:
                title = @"火车时刻";
                channelId = @"23";
                deletetitle = YES;
                break;
            case 3:
                title = @"船运时刻";
                channelId = @"24";
                deletetitle = YES;
                break;
            case 5:
                title = @"航空时刻";
                channelId = @"25";
                deletetitle = YES;
                break;
            case 6:
                title = @"常用电话";
                channelId = @"26";
                deletetitle = NO;
                break;
            case 8:
                title = @"烟台天气";
                channelId = @"21";
                deletetitle = NO;
                break;
        }
        JDOConvenienceItemController *controller = [[JDOConvenienceItemController alloc] initWithService:CONVENIENCE_SERVICE params:@{@"channelid":channelId} title:title];
        controller.deletetitle = deletetitle;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end

//
//  JDOGuideViewController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-8-1.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOGuideViewController.h"
#import "StyledPageControl.h"

@interface JDOGuideViewController () <UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *guideView;
@property (nonatomic,strong) StyledPageControl *pageControl;

@end

@implementation JDOGuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    int pages = 4;
    _guideView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, App_Height)];
    _guideView.contentSize = CGSizeMake(320*pages, App_Height);
    _guideView.pagingEnabled = true;
    _guideView.showsHorizontalScrollIndicator = false;
    _guideView.bounces = false;
    _guideView.delegate = self;
    for (int i=0; i<pages; i++) {
        UIImageView *guidePage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Guide%d",i]]];
        guidePage.frame = CGRectMake(i*320, 0, 320, App_Height);
        if(i == 3){
            UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            startBtn.frame = CGRectMake(102, App_Height-93.0f, 116, 75.0f/2);
            [startBtn setBackgroundImage:[UIImage imageNamed:@"Guide_Start"] forState:UIControlStateNormal];
            [startBtn addTarget:self action:@selector(onStartClicked:) forControlEvents:UIControlEventTouchUpInside];
            [guidePage addSubview:startBtn];
            guidePage.userInteractionEnabled = true;
        }
        [_guideView addSubview:guidePage];
    }
    [self.view addSubview:_guideView];
    
    _pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(278.0f/2,App_Height-25.0f,42,5)];
    _pageControl.diameter = 10;
    _pageControl.gapWidth = 15;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.coreNormalColor = [UIColor colorWithHex:@"A1A1A1"];
    _pageControl.coreSelectedColor = [UIColor colorWithHex:@"006FD7"];
    _pageControl.numberOfPages = 4;
    [self.view addSubview:_pageControl];
    
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    float currentPage = self.guideView.contentOffset.x / 320.0f;
//    if (currentPage  > 3.5) {
//        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//        [userDefault setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Guide"];
//        [userDefault synchronize];
//        [SharedAppDelegate enterMainView];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int currentPage = self.guideView.contentOffset.x / 320.0f;
    if (currentPage < 4) {
        _pageControl.currentPage = currentPage;
    }
}

- (void) onStartClicked:(UIButton *)sender{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithBool:true] forKey:@"JDO_Guide"];
    [userDefault synchronize];
#warning 最后一页滑动也应该可以进入主页,右上角增加skip按钮，进入主页应该增加动画过度
    [SharedAppDelegate enterMainView];
}

@end

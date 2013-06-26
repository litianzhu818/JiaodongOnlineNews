//
//  JDOImageDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-25.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageDetailController.h"
#import "JDOImageModel.h"
#import "JDOImageDetailModel.h"

@interface JDOImageDetailController ()

@property (assign, nonatomic,getter = isCollected) BOOL collected;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) MWPhotoBrowser *browser;

@end

@implementation JDOImageDetailController

- (id)initWithImageModel:(JDOImageModel *)imageModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.imageModel = imageModel;
#warning 查询是否被收藏
        self.collected = false;
        self.photos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) setupNavigationView{
    self.navigationView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Image_Title_Background.png"] ];
    [self.navigationView addLeftButtonImage:@"top_navigation_back_black" highlightImage:@"top_navigation_back_highlighted_black" target:self action:@selector(backToViewList)];
    [self.navigationView setTitle:@"浏览图集"];
}

- (void) backToViewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void)loadView{
    [super loadView];
    _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    _browser.displayActionButton = YES;
    _browser.wantsFullScreenLayout = NO;
    _browser.displayActionButton = false;
    _browser.view.frame = CGRectMake(0, 0 , 320, App_Height);

    [self.view addSubview:_browser.view];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    return true;
//}
//- (BOOL)shouldAutorotate{
//    return true;
//}
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAll;
//}

- (void)viewDidLoad{
    [super viewDidLoad];
    _browser.navigationView = self.navigationView;
    // 导航栏下面的渐变色
    
    [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_DETAIL_SERVICE modelClass:@"JDOImageDetailModel" params:@{@"aid":self.imageModel.id} success:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.photos removeAllObjects];
            JDOImageDetailModel *detailModel;
            MWPhoto *photo;
            for(int i=0; i<dataList.count; i++){
                detailModel = [dataList objectAtIndex:i];
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:[SERVER_URL stringByAppendingString:detailModel.imageurl] ]];
                photo.caption = detailModel.imagecontent;
                [_photos addObject:photo];
            }
            [_browser reloadData];
        }
    } failure:^(NSString *errorStr) {
        [JDOCommonUtil showHintHUD:errorStr inView:self.view];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_browser viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_browser viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_browser viewWillDisappear:animated];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    if(self.photos.count >0){
        MWPhoto *photo = [self.photos objectAtIndex:index];
        MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
        return captionView;
    }
    return nil;
}

@end

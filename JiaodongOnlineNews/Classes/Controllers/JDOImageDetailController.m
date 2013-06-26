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
@property (nonatomic, strong) NSMutableArray *models;
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
        self.models = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) setupNavigationView{
    self.navigationView = [[JDONavigationView alloc] initWithFrame:CGRectMake(0, 0, 320, 44+43)];
    self.navigationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    topView.image = [UIImage imageNamed:@"top_navigation_background_black.png"];
    topView.autoresizingMask =  UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.navigationView addSubview:topView];
    // 导航栏下面的渐变色
    UIImageView *gradientTopView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, 43)];
    gradientTopView.image = [UIImage imageNamed:@"top_navigation_gradient_background.png"];
    gradientTopView.autoresizingMask =  UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.navigationView addSubview:gradientTopView];
    
    [self.navigationView addLeftButtonImage:@"top_navigation_back_black" highlightImage:@"top_navigation_back_black" target:self action:@selector(backToViewList)];
    [self.navigationView setTitle:@"浏览图集"];
    
    [self.view addSubview:_navigationView];
    _browser.navigationView = self.navigationView;
}

- (void) backToViewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
}

- (void)loadView{
    [super loadView];
    _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    _browser.toolbar.shareTarget = self;
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
    // 设置导航栏
    [self setupNavigationView];
    // 设置工具栏
    [self setupToolbar];
    
    [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_DETAIL_SERVICE modelClass:@"JDOImageDetailModel" params:@{@"aid":self.imageModel.id} success:^(NSArray *dataList) {
        if(dataList.count >0){
            [self.photos removeAllObjects];
            [self.models removeAllObjects];
            JDOImageDetailModel *detailModel;
            MWPhoto *photo;
            for(int i=0; i<dataList.count; i++){
                detailModel = [dataList objectAtIndex:i];
                [_models addObject:detailModel];
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

- (void) setupToolbar{
    NSArray *toolbarBtnConfig = @[
//        [NSNumber numberWithInt:ToolBarButtonReview],
        [NSNumber numberWithInt:ToolBarButtonShare],
        [NSNumber numberWithInt:ToolBarButtonDownload],
        [NSNumber numberWithInt:ToolBarButtonCollect]
    ];
    _toolbar = [[JDOToolBar alloc] initWithModel:self.imageModel parentView:self.view config:toolbarBtnConfig height:44 theme:ToolBarThemeBlack];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _toolbar.shareTarget = self;
    _toolbar.downloadTarget = self;
    [self.view addSubview:_toolbar];
    _browser.toolbar = self.toolbar;
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

#pragma mark - share delegate

- (void)onSharedClicked{
    JDOImageDetailModel *model = (JDOImageDetailModel *)[_models objectAtIndex:_browser.currentPageIndex];
    _toolbar.model.imageurl = model.imageurl;
    _browser.toolbar.model.summary = model.imagecontent;
}

#pragma mark - download delegate

- (id) getDownloadObject{
    id<MWPhoto> photo = [_photos objectAtIndex:_browser.currentPageIndex];
    return [photo underlyingImage];
}
- (void) addObserver:(id)observer selector:(SEL)selector{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:MWPHOTO_LOADING_DID_END_NOTIFICATION object:nil];
    id<MWPhoto> photo = [_photos objectAtIndex:_browser.currentPageIndex];
    [photo loadUnderlyingImageAndNotify];
}

- (void) removeObserver:(id)observer{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:MWPHOTO_LOADING_DID_END_NOTIFICATION object:nil];
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

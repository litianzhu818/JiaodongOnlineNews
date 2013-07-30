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
#import "SDImageCache.h"
#import "JDOCommonUtil.h"

@interface JDOImageDetailController ()

@property (assign, nonatomic,getter = isCollected) BOOL collected;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) MWPhotoBrowser *browser;

@end

@implementation JDOImageDetailController{
    bool _toPortrait;
    NSArray *imageDataList;
}

- (id)initWithImageModel:(JDOImageModel *)imageModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.imageModel = imageModel;
#warning 查询是否被收藏
        self.collected = false;
        self.photos = [[NSMutableArray alloc] init];
        self.models = [[NSMutableArray alloc] init];
        
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

//- (void) orientationChanged:(NSNotification *)notif{
//    UIDeviceOrientation orientation = [[notif object] orientation];
//    
//    if (orientation == UIDeviceOrientationUnknown ||
//        orientation == UIDeviceOrientationFaceUp  ||
//        orientation == UIDeviceOrientationFaceDown){
//        return;
//    }
//    
//    if ( UIDeviceOrientationIsPortrait(orientation) ){
//        if(orientation == UIDeviceOrientationPortrait){
//            [self.view addSubview:self.navigationView];
//            [self.view addSubview:self.toolbar];
//        }else{
//            [self.navigationView removeFromSuperview];
//            [self.toolbar removeFromSuperview];
//        }
//    }else{
//        [self.navigationView removeFromSuperview];
//        [self.toolbar removeFromSuperview];
//    }
//}

- (void) setupNavigationView{
    self.navigationView = [[JDONavigationView alloc] initWithFrame:CGRectMake(0, 0, 320, 44+86)];
    self.navigationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    topView.image = [UIImage imageNamed:@"top_navigation_background_black.png"];
    topView.autoresizingMask =  UIViewAutoresizingFlexibleWidth ;
    [self.navigationView addSubview:topView];
    // 导航栏下面的渐变色
    UIImageView *gradientTopView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, 86)];
    gradientTopView.image = [UIImage imageNamed:@"top_navigation_gradient_background.png"];
    gradientTopView.autoresizingMask =  UIViewAutoresizingFlexibleWidth ;
    [self.navigationView addSubview:gradientTopView];
    
    [self.navigationView addLeftButtonImage:@"top_navigation_back_black" highlightImage:@"top_navigation_back_black" target:self action:@selector(backToViewList)];
    [self.navigationView setTitle:@"浏览图集"];
    
    [self.view addSubview:_navigationView];
    _browser.navigationView = self.navigationView;
}

- (void) backToViewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    if(self.imageDetails) {//返回新闻详情
        [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:1] animated:true];
    } else {
        [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:0] animated:true];
    }
    
}

- (void)loadView{
    [super loadView];
    _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    _browser.toolbar.shareTarget = self;
    _browser.wantsFullScreenLayout = NO;
    _browser.view.frame = CGRectMake(0, 0 , 320, App_Height);

    [self.view addSubview:_browser.view];
}

/**
 * 转屏调用顺序,其中NavigationController默认将转屏通知发送给topViewController
 * willRotateToInterfaceOrientation:
 * viewWillLayoutSubviews(iOS5以上有viewWillLayoutSubviews方法,屏幕转向的时候先执行该方法)
 * LayoutSubviews
 * willAnimateRotationToInterfaceOrientation
 * didRotateFromInterfaceOrientation
 * UIDeviceOrientationDidChangeNotification
 */

//// iOS5
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    return true;
//}
//
//// iOS6
//- (BOOL)shouldAutorotate{
//    return true;
//}
//
//// iOS6
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

/**
 * 若不覆盖NavigationController中的willRotateToInterfaceOrientation等方法,
 * 默认它会调用其topViewController中相应的方法。
 */
// 除了Portrait方向以外，其他方向都不显示导航栏和工具栏，因为回退和分享都只做了Portrait方向的导航设置
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _browser.captionView.alpha = 0;
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
        _browser.showToolbar = true;
        _toPortrait = true;
    }else{
        _browser.showToolbar = false;
        _toPortrait = false;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(!_toPortrait){
        [self.navigationView removeFromSuperview];
        [self.toolbar removeFromSuperview];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _browser.captionView.alpha = 1.0;
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
        [self.view addSubview:self.navigationView];
        [self.view addSubview:self.toolbar];
        self.navigationView.alpha = 1.0;
        self.toolbar.alpha = 1.0;
    }else{
        self.navigationView.alpha = 0;
        self.toolbar.alpha = 0;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // 设置导航栏
    [self setupNavigationView];
    // 设置工具栏
    [self setupToolbar];
    if (self.imageDetails) {//本地图片
        imageDataList = self.imageDetails;
        if(imageDataList.count > 0) {//本地图片集存在
            [self.photos removeAllObjects];
            [self.models removeAllObjects];
            JDOImageDetailModel *detailModel;
            MWPhoto *photo;
            for(int i=0; i<imageDataList.count; i++){
                detailModel = [imageDataList objectAtIndex:i];
                [_models addObject:detailModel];
                if ([[NSFileManager defaultManager] fileExistsAtPath:detailModel.localUrl isDirectory:FALSE]) {
                    photo = [MWPhoto photoWithFilePath:detailModel.localUrl];
                } else {
                    //这个图片本地不存在
                    photo = [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"base_empty_view" ofType:@"png"]];
                    photo.isImageHolder = TRUE;
                }
                photo.title = self.imageModel.title;
                photo.pages = [NSString stringWithFormat:@"%d/%d",i+1,imageDataList.count];
                photo.caption = detailModel.imagecontent;
                [_photos addObject:photo];
            }
            [_browser setCurrentPageIndex:self.imageIndex];
            [_browser reloadData];
        }
    } else {//从网络访问图片
        [[JDOJsonClient sharedClient] getJSONByServiceName:IMAGE_DETAIL_SERVICE modelClass:@"JDOImageDetailModel" params:@{@"aid":self.imageModel.id} success:^(NSArray *dataList) {
            imageDataList = dataList;
            if(dataList.count >0){
                [self.photos removeAllObjects];
                [self.models removeAllObjects];
                JDOImageDetailModel *detailModel;
                MWPhoto *photo;
                for(int i=0; i<dataList.count; i++){
                    detailModel = [dataList objectAtIndex:i];
                    [_models addObject:detailModel];
                    NSString *realUrl = [SERVER_URL stringByAppendingString:detailModel.imageurl];
                    NSString *cacheUrl = [[SDImageCache sharedImageCache] cachePathForKey:realUrl];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheUrl isDirectory:FALSE]) {//图片本地存在缓存
                        photo = [MWPhoto photoWithFilePath:cacheUrl];
                    } else {//不存在缓存，则判断3g网络下是否下载图片
                        if ([JDOCommonUtil ifNoImage]) {
                            photo = [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"base_empty_view" ofType:@"png"]];
                            photo.isImageHolder = TRUE;
                        } else {
                            photo = [MWPhoto photoWithURL:[NSURL URLWithString:realUrl]];
                        }
                    }
                    photo.title = self.imageModel.title;
                    photo.pages = [NSString stringWithFormat:@"%d/%d",i+1,dataList.count];
                    photo.caption = detailModel.imagecontent;
                    [_photos addObject:photo];
                }
                [_browser reloadData];
            }
        } failure:^(NSString *errorStr) {
            [JDOCommonUtil showHintHUD:errorStr inView:self.view];
        }];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.browser = nil;
    self.toolbar = nil;
}

- (void) setupToolbar{
    NSArray *toolbarBtnConfig = @[
//        [NSNumber numberWithInt:ToolBarButtonReview],
        [NSNumber numberWithInt:ToolBarButtonShare],
        [NSNumber numberWithInt:ToolBarButtonDownload],
        [NSNumber numberWithInt:ToolBarButtonCollect]
    ];
    _toolbar = [[JDOToolBar alloc] initWithModel:self.imageModel parentController:self typeConfig:toolbarBtnConfig widthConfig:nil frame:CGRectMake(0, App_Height-44.0, 320, 44.0) theme:ToolBarThemeBlack];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
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
    _toolbar.model.summary = model.imagecontent;
    _toolbar.model.tinyurl = model.tinyurl;
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

- (BOOL)tapToLoadImage {
    NSInteger i = [_browser currentPageIndex];
    if ([[_photos objectAtIndex:i] isImageHolder]) {
        MWPhoto *photo;
        JDOImageDetailModel *detailModel = [imageDataList objectAtIndex:i];
        
        NSString *realUrl = [SERVER_URL stringByAppendingString:detailModel.imageurl];
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:realUrl]];
        photo.title = self.imageModel.title;
        photo.pages = [NSString stringWithFormat:@"%d/%d",i+1,imageDataList.count];
        
        photo.caption = detailModel.imagecontent;
        [_photos setObject:photo atIndexedSubscript:i];
        [_browser reloadData];
        return TRUE;
    } else {
        return FALSE;
    }
}

@end

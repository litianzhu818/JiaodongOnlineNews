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

@implementation JDOImageDetailController{
    bool _toPortrait;
}

- (id)initWithImageModel:(JDOImageModel *)imageModel{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.imageModel = imageModel;
#warning 查询是否被收藏
        self.collected = false;
        self.photos = [[NSMutableArray alloc] init];
        self.models = [[NSMutableArray alloc] init];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void) orientationChanged:(NSNotification *)notif{
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
}

- (void) setupNavigationView{
    self.navigationView = [[JDONavigationView alloc] initWithFrame:CGRectMake(0, 0, 320, 44+43)];
    self.navigationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    topView.image = [UIImage imageNamed:@"top_navigation_background_black.png"];
    topView.autoresizingMask =  UIViewAutoresizingFlexibleWidth ;
    [self.navigationView addSubview:topView];
    // 导航栏下面的渐变色
    UIImageView *gradientTopView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, 43)];
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

/**
 转屏调用顺序,其中转屏通知发送给topViewController
 willRotateToInterfaceOrientation:
 viewWillLayoutSubviews
 LayoutSubviews
 willAnimateRotationToInterfaceOrientation
 didRotateFromInterfaceOrientation
 UIDeviceOrientationDidChangeNotification
 */

// iOS5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return true;
}

// iOS6
- (BOOL)shouldAutorotate{
    return true;
}

// iOS6
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


// 除了Portrait方向以外，其他方向都不显示导航栏和工具栏，因为回退和分享都只做了Portrait方向的导航设置
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    MWZoomingScrollView *page = [_browser pageDisplayedAtIndex:[_browser currentPageIndex]];
    MWCaptionView *caption = page.captionView;
    caption.alpha = 0;
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
    MWZoomingScrollView *page = [_browser pageDisplayedAtIndex:[_browser currentPageIndex]];
    MWCaptionView *caption = page.captionView;
    caption.alpha = 1.0;
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

// iOS5以上有viewWillLayoutSubviews方法,屏幕转向的时候先执行该方法,早于controller的回调和UIDevice的通知
//- (void)viewWillLayoutSubviews{
//    if([[[UIDevice currentDevice] systemVersion] compare:@"5" options:NSNumericSearch] != NSOrderedAscending){
//        [super viewWillLayoutSubviews];
//    }
//    // iOS5下未开启beginGeneratingDeviceOrientationNotifications也能接收到正确的方向
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
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
        captionView.userInteractionEnabled = false;
        return captionView;
    }
    return nil;
}

@end

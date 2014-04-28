//
//  JDOWebControllerViewController.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 13-12-30.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOWebViewController.h"
#import "UIWebView+RemoveShadow.h"
#import "WebViewJavascriptBridge_iOS.h"
#import "SDImageCache.h"
#import "JDOImageDetailController.h"
#import "JDOImageModel.h"
#import "JDOImageDetailModel.h"
#import "JDORegxpUtil.h"

#define Default_Image @"news_head_placeholder.png"

@interface JDOWebViewController ()
@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;
@end

@implementation JDOWebViewController

NSArray *imageUrls;
- (NSArray *)setupToolBarBtnConfig {
    NSArray *toolbarBtnConfig = @[
                                  [NSNumber numberWithInt:ToolBarButtonReview],
                                  [NSNumber numberWithInt:ToolBarButtonShare],
                                  [NSNumber numberWithInt:ToolBarButtonFont],
                                  [NSNumber numberWithInt:ToolBarButtonCollect]
                                  ];
    return toolbarBtnConfig;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
	self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44-44/*_toolbar.height*/)]; // 去掉导航栏和工具栏
    [self.webView makeTransparentAndRemoveShadow];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = true;
    self.webView.tag = Global_Receive_Gesture_Tag;
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    [self.rightSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.webView addGestureRecognizer:self.rightSwipeGestureRecognizer];
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    [self.leftSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.webView addGestureRecognizer:self.leftSwipeGestureRecognizer];
    
    [self.view addSubview:self.webView];
    
    _toolbar = [[JDOToolBar alloc] initWithModel:self.model parentController:self typeConfig:[self setupToolBarBtnConfig] widthConfig:nil frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];// 背景有透明渐变,高度是56不是44
    _toolbar.shareTarget = self;
    [self.view addSubview:_toolbar];
    
    self.statusView = [[JDOStatusView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
    self.statusView.delegate = self;
    [self.view addSubview:self.statusView];
    [self loadWebView];
    [self buildWebViewJavascriptBridge];
    _toolbar.bridge = _bridge;
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.toolbar action:@selector(hideReviewView)];
    _blackMask = self.view.blackMask;
    [_blackMask addGestureRecognizer:self.closeReviewGesture];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight) {// 右滑回列表页
        [self backToListView];
    }else if ( sender.direction == UISwipeGestureRecognizerDirectionLeft){// 左滑至评论页
        if ([self respondsToSelector:@selector(showReviewList)]) {
            [self performSelector:@selector(showReviewList)];
        }
    }
}

- (BOOL) onSharedClicked {
    if (self.model == nil) {
        [JDOCommonUtil showHintHUD:@"内容尚未加载！" inView:self.view];
        return FALSE;
    }
    return TRUE;
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [self.webView removeGestureRecognizer:self.rightSwipeGestureRecognizer];
    [self.webView removeGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self setWebView:nil];
    [self setToolbar:nil];
    [self setStatusView:nil];
    
    [_blackMask removeGestureRecognizer:self.closeReviewGesture];
}

- (void) backToListView{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

- (void) buildWebViewJavascriptBridge{
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    [_bridge registerHandler:@"showImageDetail" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *imageId = [(NSDictionary *)data valueForKey:@"imageId"];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        for (int i=0; i<[imageUrls count]; i++) {
            NSString *localUrl = [imageCache cachePathForKey:[imageUrls objectAtIndex:i]];
            JDOImageDetailModel *imageDetail = [[JDOImageDetailModel alloc] initWithUrl:[imageUrls objectAtIndex:i] andLocalUrl:localUrl andContent:self.model.title andTitle:self.model.title andTinyUrl:self.model.tinyurl];
            [array addObject:imageDetail];
        }
        JDOImageDetailController *detailController = [[JDOImageDetailController alloc] initWithImageModel:[[JDOImageModel alloc] init]];
        detailController.imageIndex = [imageId integerValue];
        detailController.imageDetails = array;
        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
        [centerController pushViewController:detailController animated:true];
        // 显示图片详情
        responseCallback(imageId);
    }];
    [_bridge registerHandler:@"loadImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *realUrl = [(NSDictionary *)data valueForKey:@"realUrl"];
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        UIImage *cachedImage = [imageCache imageFromKey:realUrl fromDisk:YES]; // 将需要缓存的图片加载进来
        if (cachedImage) {
            [self callJsToRefreshWebview:realUrl andLocal:[imageCache cachePathForKey:realUrl]];
        } else {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadWithURL:[NSURL URLWithString:realUrl] delegate:self storeDelegate:self];
        }
    }];
    [_bridge registerHandler:@"showImageSet" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *linkId = [(NSDictionary *)data valueForKey:@"linkId"];
        JDOImageModel *imageModel = [[JDOImageModel alloc] init];
        imageModel.id = linkId;
        JDOImageDetailController *detailController = [[JDOImageDetailController alloc] initWithImageModel:imageModel];
        JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
        // 通过pushViewController 显示图集视图
        [centerController pushViewController:detailController animated:true];
        responseCallback(linkId);
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return false;
    }
    return true;
}

// 当下载完成并且保存成功后，调用回调方法，使下载的图片显示
- (void)didFinishStoreForKey:(NSString *)key {
    NSString *realUrl = key;
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [self callJsToRefreshWebview:realUrl andLocal:[imageCache cachePathForKey:realUrl]];
}

- (id) replaceUrlAndAsyncLoadImage:(NSDictionary *) dictionary{
    NSString *html = [dictionary objectForKey:@"content"];
    
    //获取图片原始url进行异步加载，原图替换为占位图，加载结束后再替换
    imageUrls = [JDORegxpUtil getXmlTagAttrib: html andTag:@"img" andAttr:@"src"];
    for (int i=0; i<[imageUrls count]; i++) {
        NSString *realUrl = [imageUrls objectAtIndex:i];
        //更改图片为占位图
        NSMutableString *replaceWithString = [[NSMutableString alloc] init];
        [replaceWithString appendString:Default_Image];
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:realUrl fromDisk:YES];
        if ([JDOCommonUtil ifNoImage] && !cachedImage) {
            [replaceWithString appendString:@"\" tapToLoad=\"true"];
        }
        [replaceWithString appendString:@"\" realUrl=\""];
        [replaceWithString appendString:realUrl];
        html = [html stringByReplacingOccurrencesOfString:realUrl withString:replaceWithString];
    }
    NSMutableDictionary *newsDetail = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    [newsDetail setObject:html forKey:@"content"];
    if ([dictionary objectForKey:@"advs"] != nil) {
        NSString *adv_img = [SERVER_RESOURCE_URL stringByAppendingString:[(NSDictionary *)[(NSArray *)[dictionary objectForKey:@"advs"] objectAtIndex:0] objectForKey:@"mpic"]];
        [newsDetail setObject:adv_img forKey:@"adv"];
    }
    return newsDetail;
}

-(void) callJsToRefreshWebview:(NSString *)realUrl andLocal:(NSString *) localUrl {
    //图片加载成功，调用js，刷新图片
    NSMutableString *js = [[NSMutableString alloc] init];
    [js appendString:@"refreshImg('"];
    [js appendString:realUrl];
    [js appendString:@"', '"];
    [js appendString:localUrl];
    [js appendString:@"')"];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    
}
- (void) loadWebView{}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadWebView];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadWebView];
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.webView.hidden = false;
    }else{
        self.webView.hidden = true;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self setCurrentState:ViewStatusRetry];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self setCurrentState:ViewStatusNormal];
    //webview加载完成，再开始异步加载图片
    if(imageUrls) {
        for (int i=0; i<[imageUrls count]; i++) {
            NSString *realUrl = [imageUrls objectAtIndex:i];
            NSURL *url = [NSURL URLWithString:realUrl];
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            UIImage *cachedImage = [imageCache imageFromKey:realUrl fromDisk:YES]; // 将需要缓存的图片加载进来
            if (cachedImage) {
                [self callJsToRefreshWebview:realUrl andLocal:[imageCache cachePathForKey:realUrl]];
            } else {
                if ([JDOCommonUtil ifNoImage]) {//3g下，不下载图片
                    [self callJsToRefreshWebview:realUrl andLocal:@"base_empty_view.png"];
                } else {
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    [manager downloadWithURL:url delegate:self storeDelegate:self];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

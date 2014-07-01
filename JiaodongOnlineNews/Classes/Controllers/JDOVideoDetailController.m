//
//  JDOVideoDetailController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-19.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoDetailController.h"
#import "JDOVideoModel.h"
#import "JDOToolBar.h"
#import "JDOReviewListController.h"
#import "FXLabel.h"
#import "JDODataModel.h"
#import "DCParserConfiguration.h"
#import "DCCustomParser.h"
#import "DCKeyValueObjectMapping.h"

#import "Utilities.h"
#import "VSegmentSlider.h"
#import "JDOVideoEPG.h"
#import "JDOVideoEPGList.h"

#define Dept_Label_Tag 101
#define Title_Label_Tag 102
#define Subtitle_Label_Tag 103
#define Secret_Field_Tag 104

#define Content_Font_Size 16.0f
#define Subtitle_Font_Size 14.0f
#define kBackviewDefaultRect		CGRectMake(20, 47, 280, 180)


@interface JDOVideoDetailController ()
{
    VMediaPlayer       *mMPayer;
    long               mDuration;
    long               mCurPostion;
    NSTimer            *mSyncSeekTimer;
    BOOL               isCtrlHide;
    BOOL               isEpgFold;
}

@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIButton *startPause;
@property (nonatomic, assign) IBOutlet UIButton *prevBtn;
@property (nonatomic, assign) IBOutlet UIButton *nextBtn;
@property (nonatomic, assign) IBOutlet UIButton *modeBtn;
@property (nonatomic, assign) IBOutlet UIButton *reset;
@property (nonatomic, assign) IBOutlet VSegmentSlider *progressSld;
@property (nonatomic, assign) IBOutlet UILabel  *curPosLbl;
@property (nonatomic, assign) IBOutlet UILabel  *bubbleMsgLbl;
@property (nonatomic, assign) IBOutlet UILabel  *downloadRate;
@property (nonatomic, assign) IBOutlet UIView  	*activityCarrier;
@property (nonatomic, assign) IBOutlet UIView  	*backView;
@property (nonatomic, assign) IBOutlet UIView  	*carrier;
@property (strong, nonatomic) IBOutlet UIImageView *controlBackground;

@property (nonatomic, copy)   NSURL *videoURL;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL progressDragging;


@end

@implementation JDOVideoDetailController

- (id)initWithModel:(JDOVideoModel *)videoModel{
    self = [super init];
    if (self) {
        self.videoModel = videoModel;
        self.videoURL = [NSURL URLWithString:[videoModel.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}

- (void) onRetryClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) onNoNetworkClicked:(JDOStatusView *) statusView{
    [self loadDataFromNetwork];
}

- (void) setCurrentState:(ViewStatusType)status{
    _status = status;
    
    self.statusView.status = status;
    if(status == ViewStatusNormal){
        self.mainView.hidden = false;
        self.toolbar.hidden = false;
    }else{
        self.mainView.hidden = true;
        self.toolbar.hidden = true;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // 内容
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
    
    _mainView.frame = CGRectMake(0, Is_iOS7?64:44, 320, App_Height-(Is_iOS7?64:44));
    _mainView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
						  UIActivityIndicatorViewStyleWhiteLarge];
	[self.activityCarrier addSubview:self.activityView];
    
	UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc]
								   initWithTarget:self
								   action:@selector(progressSliderTapped:)];
    [self.progressSld addGestureRecognizer:gr];
    [self.progressSld setThumbImage:[UIImage imageNamed:@"video_seekbar_btn"] forState:UIControlStateNormal];
    [self.progressSld setMinimumTrackImage:[UIImage imageNamed:@"video_seekbar_front"] forState:UIControlStateNormal];
    [self.progressSld setMaximumTrackImage:[UIImage imageNamed:@"video_seekbar_back"] forState:UIControlStateNormal];
    //
    self.progressSld.hidden = true;
    self.curPosLbl.hidden = true;
    
	if (!mMPayer) {
		mMPayer = [VMediaPlayer sharedInstance];
		[mMPayer setupPlayerWithCarrierView:self.carrier withDelegate:self];
		[self setupObservers];
	}
    UITapGestureRecognizer *ctrlSwitchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchCtrlState)];
    [self.carrier addGestureRecognizer:ctrlSwitchTap];
    
//    self.statusView = [[JDOStatusView alloc] initWithFrame:CGRectMake(0, 44, 320, App_Height-44)];
//    self.statusView.delegate = self;
//    [self.view addSubview:self.statusView];
//    [self loadDataFromNetwork];
    
    
    // 播放界面的节目单只显示当天的
    _epg = [[JDOVideoEPG alloc] initWithFrame:CGRectMake(0, 241-Navbar_Height, 320, CGRectGetHeight(_mainView.bounds)-241+Navbar_Height-44/*工具栏*/) model:self.videoModel delegate:self];
    _epg.scrollView.pagingScrollView.scrollEnabled = false; // 弹出节目单之前禁用横向滚动
    isEpgFold = true;
    [_mainView addSubview:_epg];
    [_mainView sendSubviewToBack:_epg];
    
//    JDOVideoEPGList *todayEpg = [[JDOVideoEPGList alloc] initWithFrame:CGRectMake(0, 241, 320, CGRectGetHeight(_mainView.bounds)-241-44/*工具栏*/) identifier:nil];
//    todayEpg.videoModel = self.videoModel;
//    todayEpg.delegate = self;
//    todayEpg.tableView.scrollsToTop = true;
//    [todayEpg loadDataFromNetwork];
//    [_mainView addSubview:todayEpg];
    
    NSArray *toolbarBtnConfig = @[[NSNumber numberWithInt:ToolBarButtonReview],[NSNumber numberWithInt:ToolBarButtonVideoEpg],[NSNumber numberWithInt:ToolBarButtonShare]];
    _toolbar = [[JDOToolBar alloc] initWithModel:self.videoModel parentController:self typeConfig:toolbarBtnConfig widthConfig:nil frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];
    _toolbar.videoTarget = self;
    _toolbar.shareTarget = self;
    [self.view addSubview:_toolbar];
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.toolbar action:@selector(hideReviewView)];
    self.blackMask = [self.view blackMask];
    [_blackMask addGestureRecognizer:self.closeReviewGesture];
    
    // 加载视频
    [self quicklyPlayMovie:[self playCtrlGetCurrMediaURL] title:nil];
}

- (void) onEpgClicked{
#warning 若评论窗口打开，则先关闭评论视图
    if(isEpgFold){
        _epg.scrollView.pagingScrollView.scrollEnabled = true;
        [_mainView bringSubviewToFront:_epg];
    }else{
        _epg.scrollView.pagingScrollView.scrollEnabled = false;
        [_mainView sendSubviewToBack:_epg];
    }
    isEpgFold = !isEpgFold;
}

- (BOOL) onSharedClicked{
    return true;
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [mMPayer unSetupPlayer];
    [self setToolbar:nil];
    [_blackMask removeGestureRecognizer:self.closeReviewGesture];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
//	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
//	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)dealloc{
	[self unSetupObservers];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
	return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)to duration:(NSTimeInterval)duration{
//	if (UIInterfaceOrientationIsLandscape(to)) {
//		self.backView.frame = self.view.bounds;
//	} else {
//		self.backView.frame = kBackviewDefaultRect;
//	}
	NSLog(@"NAL 1HUI &&&&&&&&& frame=%@", NSStringFromCGRect(self.carrier.frame));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	NSLog(@"NAL 2HUI &&&&&&&&& frame=%@", NSStringFromCGRect(self.carrier.frame));
}


#pragma mark - Respond to the Remote Control Events

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlTogglePlayPause:
			if ([mMPayer isPlaying]) {
				[mMPayer pause];
			} else {
				[mMPayer start];
			}
			break;
		case UIEventSubtypeRemoteControlPlay:
			[mMPayer start];
			break;
		case UIEventSubtypeRemoteControlPause:
			[mMPayer pause];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:

			break;
		case UIEventSubtypeRemoteControlNextTrack:

			break;
		default:
			break;
	}
}

- (void)applicationDidEnterForeground:(NSNotification *)notification
{
	[mMPayer setVideoShown:YES];
    if (![mMPayer isPlaying]) {
		[mMPayer start];
		[self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
	}
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if ([mMPayer isPlaying]) {
		[mMPayer pause];
		[mMPayer setVideoShown:NO];
    }
}

#pragma mark - Navigation

- (void) setupNavigationView{
    [self.navigationView addBackButtonWithTarget:self action:@selector(backToViewList)];
    [self.navigationView setTitle:self.videoModel.name];
    [self.navigationView addRightButtonImage:@"top_navigation_review" highlightImage:@"top_navigation_review" target:self action:@selector(showReviewList)];
}

- (void) backToViewList{
    [self quicklyStopMovie];
    [mMPayer unSetupPlayer];
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

- (void) showReviewList{
    // 是否显示评论?
//    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
//    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithType:JDOReviewTypeLivehood params:@{@"qid":self.questionModel.id}];
//    [centerViewController pushViewController:reviewController animated:true];
}

- (void)loadDataFromNetwork{
//    [self setCurrentState:ViewStatusLoading];
    [self setCurrentState:ViewStatusNormal];
    
    // 节目列表视图应独立出去，否则该类太庞大

//    DCParserConfiguration *config = [DCParserConfiguration configuration];
//    DCCustomParser *customParser = [[DCCustomParser alloc] initWithBlockParser:^id(NSDictionary *dictionary, NSString *attributeName, __unsafe_unretained Class destinationClass, id value) {
//        DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[JDOQuestionDetailModel class]];
//        return [mapper parseDictionary:value];
//    } forAttributeName:@"_data" onDestinationClass:[JDODataModel class]];
//    [config addCustomParsersObject:customParser];
//    
//    NSDictionary *params = self.isMine? @{@"info_id":self.questionModel.id, @"checked": @"0"}:@{@"info_id":self.questionModel.id};
//    
//    [[JDOJsonClient sharedClient] getJSONByServiceName:QUESTION_DETAIL_SERVICE modelClass:@"JDODataModel" config:config params:params success:^(JDODataModel *dataModel) {
//        if(dataModel != nil && [dataModel.status intValue] ==1 && dataModel.data != nil){
//            JDOQuestionDetailModel *data = (JDOQuestionDetailModel *)dataModel.data;
//            self.questionModel.dept_code = data.dept_code ;  // 提交评论时用到dept_code
//            [self dataLoadFinished: data];
//            [self setCurrentState:ViewStatusNormal];
//        }else{
//            // 服务器端有错误
//            [self setCurrentState:ViewStatusRetry];
//        }
//    } failure:^(NSString *errorStr) {
//        NSLog(@"错误内容--%@", errorStr);
//        [self setCurrentState:ViewStatusRetry];
//    }];
}


#pragma mark VMediaPlayerDelegate Implement / Required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [player setVideoFillMode:VMVideoFillModeFit];
    [player start];
    
	[self setBtnEnableStatus:YES];
	[self stopActivity];
    if ( !isCtrlHide ) { // 若control栏是显示状态，则加载完成2秒后自动隐藏
        [self performSelector:@selector(switchCtrlState) withObject:nil afterDelay:2.0];
    }
    
    mDuration = [player getDuration];
    if (mDuration == 0) { // 取不到总时长，则认为是直播流，不显示播放时间和进度条
        self.progressSld.hidden = true;
        self.curPosLbl.hidden = true;
    }else{
        self.progressSld.hidden = false;
        self.curPosLbl.hidden = false;
        mSyncSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/3 target:self selector:@selector(syncSliderUIStatus) userInfo:nil repeats:YES];
    }
    
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
	[self goBackButtonAction:nil];
}

- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
	NSLog(@"NAL 1RRE &&&& VMediaPlayer Error: %@", arg);
	[self stopActivity];
	[self showVideoLoadingError];
	[self setBtnEnableStatus:YES];
}

- (void)mediaPlayer:(VMediaPlayer *)player info:(id)arg{
    NSLog(@"NAL 1RRE &&&& VMediaPlayer Info: %@", arg);
}

- (void)mediaPlayer:(VMediaPlayer *)player decodingSchemeChanged:(id)arg{
    NSLog(@"切换解码方案，从%@切换到%@", arg[0],arg[1]);
}

#pragma mark VMediaPlayerDelegate Implement / Optional

- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
    // 烟台手机台m3u8格式的历史节目视频,不同的解码格式有如下特点:
    // 策略                              seek(进度)      buffer(缓冲)    getFrame(帧图片)
    // VMDecodingSchemeQuickTime           Y                N                N
    // VMDecodingSchemeHardware            N                Y                N
    // VMDecodingSchemeSoftware            N                Y                Y
	player.decodingSchemeHint = VMDecodingSchemeQuickTime;
	player.autoSwitchDecodingScheme = true;
}

- (void)mediaPlayer:(VMediaPlayer *)player setupPlayerPreference:(id)arg
{
	// Set buffer size, default is 1024KB(1*1024*1024).
	[player setBufferSize:512*1024];
    [player setAdaptiveStream:YES]; // 改善对流媒体支持，支持HLS自适应码率，需要手动开启
    
	[player setVideoQuality:VMVideoQualityHigh];    // VMVideoQualityLow(默认) ,VMVideoQualityMedium ,VMVideoQualityHigh
    // 开启缓存时候，第二次播放直播流会无法播放，貌似是因为缓存文件.vit被lock无法再次写入造成
    [player setUseCache:true];
	[player setCacheDirectory:[self getCacheRootDirectory]];
}

- (void)mediaPlayer:(VMediaPlayer *)player seekComplete:(id)arg
{
    NSLog(@"NAL 1HBT &&&&&&&&&&&&&&&&...seekComplete....&&&&&&&&&&&&&&&&&");
    if (![Utilities isLocalMedia:self.videoURL] && player.decodingSchemeUsing == VMDecodingSchemeQuickTime) {
		[self stopActivity];
	}
    self.progressDragging = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player notSeekable:(id)arg
{
	self.progressDragging = NO;
	NSLog(@"NAL 1HBT &&&&&&&&&&&&&&&&...notSeekable....&&&&&&&&&&&&&&&&&");
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
	self.progressDragging = YES;
	NSLog(@"NAL 2HBT &&&&&&&&&&&&&&&&...bufferingStart....&&&&&&&&&&&&&&&&&");
	if (![Utilities isLocalMedia:self.videoURL]) {
		[player pause];
		[self.startPause setTitle:@"Start" forState:UIControlStateNormal];
		[self startActivityWithMsg:@"Buffering... 0%"];
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg
{
	if (!self.bubbleMsgLbl.hidden) {
		self.bubbleMsgLbl.text = [NSString stringWithFormat:@"Buffering... %d%%",
								  [((NSNumber *)arg) intValue]];
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
	if (![Utilities isLocalMedia:self.videoURL]) {
		[player start];
		[self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
		[self stopActivity];
	}
	self.progressDragging = NO;
	NSLog(@"NAL 3HBT &&&&&&&&&&&&&&&&....bufferingEnd...&&&&&&&&&&&&&&&&&");
}

- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
	if (![Utilities isLocalMedia:self.videoURL]) {
		self.downloadRate.text = [NSString stringWithFormat:@"%dKB/s", [arg intValue]];
	} else {
		self.downloadRate.text = nil;
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player videoTrackLagging:(id)arg
{
	NSLog(@"NAL 1BGR video lagging....");
}

#pragma mark VMediaPlayerDelegate Implement / Cache

- (void)mediaPlayer:(VMediaPlayer *)player cacheNotAvailable:(id)arg
{
	NSLog(@"NAL .... media can't cache.");
	self.progressSld.segments = nil;
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheStart:(id)arg
{
	NSLog(@"NAL 1GFC .... media caches index : %@", arg);
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheUpdate:(id)arg
{
	NSArray *segs = (NSArray *)arg;
    NSLog(@"NAL .... media cacheUpdate, %d, %@", segs.count, segs);
	if (mDuration > 0) {
		NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
		for (int i = 0; i < segs.count; i++) {
			float val = (float)[segs[i] longLongValue] / mDuration;
			[arr addObject:[NSNumber numberWithFloat:val]];
		}
		self.progressSld.segments = arr;
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheSpeed:(id)arg
{
    NSLog(@"NAL .... media cacheSpeed: %dKB/s", [(NSNumber *)arg intValue]);
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheComplete:(id)arg
{
	NSLog(@"NAL .... media cacheComplete");
	self.progressSld.segments = @[@(0.0), @(1.0)];
}


#pragma mark - Convention Methods

-(void)quicklyPlayMovie:(NSURL*)url title:(NSString*)title
{
	[UIApplication sharedApplication].idleTimerDisabled = YES;// 禁止系统自动关闭屏幕
    //	[self setBtnEnableStatus:NO];
    [mMPayer setDataSource:url header:nil];
    
    //	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:0];
    //	NSMutableArray *vals = [NSMutableArray arrayWithCapacity:0];
    //	keys[0] = @"-rtmp_live";
    //	vals[0] = @"-1";
    //	[mMPayer setOptionsWithKeys:keys withValues:vals];
    
    [mMPayer prepareAsync];
	[self startActivityWithMsg:@"正在加载..."];
    isCtrlHide = true;
    [self switchCtrlState];
}

-(void)quicklyStopMovie
{
	[mMPayer reset];
	[mSyncSeekTimer invalidate];
	mSyncSeekTimer = nil;
	self.progressSld.value = 0.0;
	self.progressSld.segments = nil;
	self.curPosLbl.text = [self getCurrentProgressLabel:0]; //@"00:00:00";
	self.downloadRate.text = nil;
	mDuration = 0;
	mCurPostion = 0;
	[self stopActivity];
	[self setBtnEnableStatus:YES];
	[UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - UI Actions

-(IBAction)goBackButtonAction:(id)sender
{
	[self quicklyStopMovie];
}

-(IBAction)startPauseButtonAction:(id)sender
{
	BOOL isPlaying = [mMPayer isPlaying];
	if (isPlaying) {
		[mMPayer pause];
		[self.startPause setTitle:@"Start" forState:UIControlStateNormal];
	} else {
		[mMPayer start];
		[self.startPause setTitle:@"Pause" forState:UIControlStateNormal];
	}
}

-(IBAction)switchVideoViewModeButtonAction:(id)sender{
	static emVMVideoFillMode modes[] = {
		VMVideoFillModeFit,
		VMVideoFillMode100,
		VMVideoFillModeCrop,
		VMVideoFillModeStretch,
	};
	static int curModeIdx = 0;
    
	curModeIdx = (curModeIdx + 1) % (int)(sizeof(modes)/sizeof(modes[0]));
	[mMPayer setVideoFillMode:modes[curModeIdx]];
}

-(IBAction)resetButtonAction:(id)sender{
	static int bigView = 0;
    
	[UIView animateWithDuration:0.3 animations:^{
		if (bigView) {
			self.backView.frame = kBackviewDefaultRect;
			bigView = 0;
		} else {
			self.backView.frame = self.view.bounds;
			bigView = 1;
		}
		NSLog(@"NAL 1NBV &&&& backview.frame=%@", NSStringFromCGRect(self.backView.frame));
	}];
    
    
    //	[self quicklyStopMovie];
}

-(IBAction)progressSliderDownAction:(id)sender
{
	self.progressDragging = YES;
	NSLog(@"NAL 1DOW &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Touch Down");
}

-(IBAction)progressSliderUpAction:(id)sender
{
	UISlider *sld = (UISlider *)sender;
	NSLog(@"NAL 1BVC &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& seek = %ld", (long)(sld.value * mDuration));
	[self startActivityWithMsg:@"加载中..."];
	[mMPayer seekTo:(long)(sld.value * mDuration)];
}

-(IBAction)dragProgressSliderAction:(id)sender
{
	UISlider *sld = (UISlider *)sender;
	self.curPosLbl.text = [self getCurrentProgressLabel:(long)(sld.value * mDuration)];
}

-(void)progressSliderTapped:(UIGestureRecognizer *)g
{
    UISlider* s = (UISlider*)g.view;
    if (s.highlighted)
        return;
    CGPoint pt = [g locationInView:s];
    CGFloat percentage = pt.x / s.bounds.size.width;
    CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
    CGFloat value = s.minimumValue + delta;
    [s setValue:value animated:YES];
    long seek = percentage * mDuration;
	self.curPosLbl.text = [self getCurrentProgressLabel:seek];
	NSLog(@"NAL 2BVC &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& seek = %ld", seek);
	[self startActivityWithMsg:@"加载中..."];
    [mMPayer seekTo:seek];
}

#pragma mark - Sync UI Status

-(void)syncSliderUIStatus
{
	if (!self.progressDragging) {
		mCurPostion  = [mMPayer getCurrentPosition];
		[self.progressSld setValue:(float)mCurPostion/mDuration];
        NSLog(@"进度条:%g",(float)mCurPostion/mDuration);
		self.curPosLbl.text = [self getCurrentProgressLabel:mCurPostion];
	}
}

-(NSString *) getCurrentProgressLabel:(long) currentPostion{
    return [NSString stringWithFormat:@"%@/%@",[Utilities timeToHumanString:currentPostion],[Utilities timeToHumanString:mDuration]];
}


#pragma mark Others

-(void)startActivityWithMsg:(NSString *)msg
{
	self.bubbleMsgLbl.hidden = NO;
	self.bubbleMsgLbl.text = msg;
	[self.activityView startAnimating];
}

-(void)stopActivity
{
	self.bubbleMsgLbl.hidden = YES;
	self.bubbleMsgLbl.text = nil;
	[self.activityView stopAnimating];
}

-(void)setBtnEnableStatus:(BOOL)enable
{
	self.startPause.enabled = enable;
	self.prevBtn.enabled = enable;
	self.nextBtn.enabled = enable;
	self.modeBtn.enabled = enable;
}

-(void)switchCtrlState{
    isCtrlHide = !isCtrlHide;
    if ( isCtrlHide ) {
        [UIView animateWithDuration:0.5f animations:^{
            self.controlBackground.alpha = 0;
            self.progressSld.alpha = 0;
            self.curPosLbl.alpha = 0;
        }];
    }else{
        [UIView animateWithDuration:1.0f animations:^{
            self.controlBackground.alpha = 1;
            self.progressSld.alpha = 1;
            self.curPosLbl.alpha = 1;
        }];
    }
}

- (void)setupObservers
{
	NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self
			selector:@selector(applicationDidEnterForeground:)
				name:UIApplicationDidBecomeActiveNotification
			  object:[UIApplication sharedApplication]];
    [def addObserver:self
			selector:@selector(applicationDidEnterBackground:)
				name:UIApplicationWillResignActiveNotification
			  object:[UIApplication sharedApplication]];
}

- (void)unSetupObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)showVideoLoadingError
{
	NSString *sError = NSLocalizedString(@"Video cannot be played", @"description");
	NSString *sReason = NSLocalizedString(@"Video cannot be loaded.", @"reason");
	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   sError, NSLocalizedDescriptionKey,
							   sReason, NSLocalizedFailureReasonErrorKey,
							   nil];
	NSError *error = [NSError errorWithDomain:@"Vitamio" code:0 userInfo:errorDict];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

- (NSString *)getCacheRootDirectory
{
	NSString *cache = [NSString stringWithFormat:@"%@/Library/Caches/MediasCaches", NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cache]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cache
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
    }
	return cache;
}

- (NSURL *)playCtrlGetCurrMediaURL{

    NSURL *url=[NSURL URLWithString:[self.videoModel.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSString *m3u8 = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"m3u8 content:%@",m3u8);
    return url;
    
    // 以下为测试地址
//    return [NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sohu.m3u8"]];
//    return [NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ytv.m3u8"]];
//	return [NSURL URLWithString:[self.videoModel.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    return [NSURL URLWithString:@"http://hot.vrs.sohu.com/ipad1407291_4596271359934_4618512.m3u8"];
//    return [NSURL URLWithString:@"http://live1.av.jiaodong.net/channels/yttv/video_yt1/m3u8:500k/1400430735000,1400430855000,120000"];// YTV-1糖果剧
//    return [NSURL URLWithString:@"http://cibn1.vdnplus.com/channels/tvie/CCTV-1/m3u8:sd/1400433840000,1400435880000,2040000"];// CCTV-1动物世界
//    return [NSURL URLWithString:@"http://vod.av.jiaodong.net/vod_storage/vol1/2014/03/19/5328fce906a83/01b70087af0c11e3a5fa848f69e075fe.mp4"];
//    return [NSURL URLWithString:@"http://live1.av.jiaodong.net/channels/yttv/video_yt1/m3u8:500k/1398129434000,1398129438000,5000"];
}

- (void) onVideoChanged:(JDOVideoEPGModel *)epgModel{
    NSURL *url;
    if(epgModel.state == JDOVideoStatePlayback){
        long startTime = [NSNumber numberWithDouble:[epgModel.start_time timeIntervalSince1970]].longValue;
        long endTime = [NSNumber numberWithDouble:[epgModel.end_time timeIntervalSince1970]].longValue;
        url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/%ld000,%ld000,5000",self.videoModel.liveUrl,startTime,endTime] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else if(epgModel.state == JDOVideoStateLive){
        url = [NSURL URLWithString:[self.videoModel.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else if(epgModel.state == JDOVideoStateForecast){
        // 预报节目不可播放
    }else{
        NSLog(@"节目状态未知");
    }
	if (url) {
		[self quicklyStopMovie];
        [self quicklyPlayMovie:url title:epgModel.name];
	}
}

- (NSURL *)playCtrlGetNextMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos{
    return [NSURL URLWithString:@"http://hot.vrs.sohu.com/ipad1407291_4596271359934_4618512.m3u8"];
}

- (NSURL *)playCtrlGetPrevMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos{
    return [NSURL URLWithString:[self.videoModel.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


@end

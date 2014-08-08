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
#import <math.h>

#define Player_Height 241

#define Dept_Label_Tag 101
#define Title_Label_Tag 102
#define Subtitle_Label_Tag 103
#define Secret_Field_Tag 104

#define Content_Font_Size 16.0f
#define Subtitle_Font_Size 14.0f
#define kBackviewDefaultRect		CGRectMake(0, 47, 280, 180)


@interface JDOVideoDetailController ()
{
    VMediaPlayer       *mMPayer;
    long               mDuration;
    long               mCurPostion;
    NSTimer            *mSyncSeekTimer;
    BOOL               isCtrlHide;
    BOOL               isPlayerUnsetup;
}

@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, assign) IBOutlet UIButton *startPause;
@property (nonatomic, assign) IBOutlet UIButton *fullHalf;
@property (nonatomic, assign) IBOutlet VSegmentSlider *progressSld;
@property (nonatomic, assign) IBOutlet UILabel  *curPosLbl;
@property (nonatomic, assign) IBOutlet UILabel  *bubbleMsgLbl;
@property (nonatomic, assign) IBOutlet UILabel  *downloadRate;
@property (nonatomic, assign) IBOutlet UIView  	*activityCarrier;
@property (nonatomic, assign) IBOutlet UIView  	*carrier;
@property (strong, nonatomic) IBOutlet UIImageView *controlBackground;

@property (nonatomic, copy)   NSURL *videoURL;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL progressDragging;

@property (nonatomic, strong) JDOVideoEPGModel *currentEpgModel;
@property (nonatomic, strong) NSArray *currentEpgList;

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
    self.view.backgroundColor = [UIColor clearColor];
    
    _mainView.frame = CGRectMake(0, 0, 320, (Is_iOS7?64:44)+Player_Height);
    _mainView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    self.backView.frame = CGRectMake(0, Is_iOS7?64:44, 320, Player_Height);
    
    [self.navigationView removeFromSuperview];
    [_mainView addSubview:self.navigationView];
    
	self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
						  UIActivityIndicatorViewStyleWhiteLarge];
	[self.activityCarrier addSubview:self.activityView];
    
	UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc]
								   initWithTarget:self
								   action:@selector(progressSliderTapped:)];
//    self.progressSld.frame = CGRectMake(-20, 190, 360, 29); // 滑块有渐变透明，实际比可视大小大很多,设置更大的宽度来隐藏渐变部分
    [self.progressSld addGestureRecognizer:gr];
    [self.progressSld setThumbImage:[UIImage imageNamed:@"video_seekbar_btn"] forState:UIControlStateNormal];
    [self.progressSld setMinimumTrackImage:[UIImage imageNamed:@"video_seekbar_front"] forState:UIControlStateNormal];
    [self.progressSld setMaximumTrackImage:[UIImage imageNamed:@"video_seekbar_back"] forState:UIControlStateNormal];
    //
    self.progressSld.hidden = true;
//    self.curPosLbl.hidden = true;
    
	if (!mMPayer) {
		mMPayer = [VMediaPlayer sharedInstance];
		[mMPayer setupPlayerWithCarrierView:self.carrier withDelegate:self];
		[self setupObservers];
        isPlayerUnsetup = false;
	}
    UITapGestureRecognizer *ctrlSwitchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchCtrlState)];
    [self.carrier addGestureRecognizer:ctrlSwitchTap];
    self.controlBackground.userInteractionEnabled = true; // 启用工具栏的事件，避免在工具栏点击时事件向下传递导致关闭工具栏
    
    CGRect frame1 = CGRectMake(0, (Is_iOS7?64:44)+Player_Height, 320, App_Height-(Is_iOS7?64:44)-Player_Height-44/*工具栏*/);
    CGRect frame2 = CGRectMake(0, (Is_iOS7?64:44)+Player_Height-Navbar_Height, 320, App_Height-(Is_iOS7?64:44)-110/*播放器*/-44);
    _epg = [[JDOVideoEPG alloc] initWithFoldFrame:frame1 fullFrame:frame2 model:self.videoModel delegate:self];
    [self.view addSubview:_epg];
    
    
    NSArray *toolbarBtnConfig = @[[NSNumber numberWithInt:ToolBarButtonReview],[NSNumber numberWithInt:ToolBarButtonVideoEpg],[NSNumber numberWithInt:ToolBarButtonShare]];
    // 使用专门定义的一条新闻id作为评论的入口
    self.videoModel.id = @"31317";
    _toolbar = [[JDOToolBar alloc] initWithModel:self.videoModel parentController:self typeConfig:toolbarBtnConfig widthConfig:nil frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];
    _toolbar.videoTarget = self;
    _toolbar.shareTarget = self;
    [self.view addSubview:_toolbar];
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.toolbar action:@selector(hideReviewView)];
    self.blackMask = [self.view blackMask];
    [_blackMask addGestureRecognizer:self.closeReviewGesture];
    
    // 加载视频
    [self quicklyPlayMovie:[self getCurrMediaURL] title:nil];
}

- (void) onEpgClicked{
    UIView *epgMask = [self.mainView blackMask];
    if (epgMask.gestureRecognizers.count == 0) {
        [epgMask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEpgClicked)]];
    }
    
    if(self.epg.isFold){
        [self.epg switchFoldState];
        
        [(UIButton *)[self.toolbar.btns objectForKey:[NSNumber numberWithInt:ToolBarButtonReview]] setEnabled:false];
        [(UIButton *)[self.toolbar.btns objectForKey:[NSNumber numberWithInt:ToolBarButtonShare]] setEnabled:false];
        epgMask.alpha = 0;
        [self.view insertSubview:epgMask aboveSubview:self.mainView];

        [UIView animateWithDuration:.35f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect f = _epg.frame;
            f.origin.y = (Is_iOS7?64:44)+110;
            _epg.frame = f;
            self.mainView.transform = CGAffineTransformMakeScale(Min_Scale, Min_Scale);
            epgMask.alpha = Max_Alpah;
        } completion:^(BOOL finished) {

        }];
    }else{
        
        [(UIButton *)[self.toolbar.btns objectForKey:[NSNumber numberWithInt:ToolBarButtonReview]] setEnabled:true];
        [(UIButton *)[self.toolbar.btns objectForKey:[NSNumber numberWithInt:ToolBarButtonShare]] setEnabled:true];
        
        [UIView animateWithDuration:.35f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _epg.frame = _epg.fullFrame;
            self.mainView.transform = CGAffineTransformIdentity;
            epgMask.alpha = 0;
        } completion:^(BOOL finished) {
            [epgMask removeFromSuperview];
            [self.epg switchFoldState];
        }];
    }
}

- (BOOL) onSharedClicked{
    return true;
}

-(void)viewDidUnload{
    [super viewDidUnload];
    [mMPayer unSetupPlayer];
    isPlayerUnsetup = true;
    [self setToolbar:nil];
    [_blackMask removeGestureRecognizer:self.closeReviewGesture];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
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

- (void)applicationDidEnterForeground:(NSNotification *)notification
{
    if (isPlayerUnsetup) {
        return;
    }
	[mMPayer setVideoShown:YES];
    if (![mMPayer isPlaying]) {
		[mMPayer start];
		self.startPause.selected = true;
	}
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (isPlayerUnsetup) {
        return;
    }
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
    isPlayerUnsetup = true;
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    [centerViewController popToViewController:[centerViewController.viewControllers objectAtIndex:centerViewController.viewControllers.count-2] animated:true];
}

- (void) showReviewList{
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithType:JDOReviewTypeNews params:@{@"aid":self.videoModel.id,@"deviceId":JDOGetUUID()}];
    reviewController.model = self.videoModel;
    [centerViewController pushViewController:reviewController animated:true];
}

- (void)loadDataFromNetwork{
//    [self setCurrentState:ViewStatusLoading];
    [self setCurrentState:ViewStatusNormal];

}


#pragma mark VMediaPlayerDelegate Implement / Required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    // 使用static的样例代码
//    static emVMVideoFillMode modes[] = {
//		VMVideoFillModeFit,
//		VMVideoFillMode100, // 原始大小
//		VMVideoFillModeCrop,
//		VMVideoFillModeStretch,
//	};
//	static int curModeIdx = 0;
//    
//	curModeIdx = (curModeIdx + 1) % (int)(sizeof(modes)/sizeof(modes[0]));
//	[mMPayer setVideoFillMode:modes[curModeIdx]];
    
    [player setVideoFillMode:VMVideoFillModeStretch];
    [player start];
    
	[self setBtnEnableStatus:YES];
    self.startPause.selected = true; // 暂停
	[self stopActivity];
    
    mDuration = [player getDuration];
    if (mDuration == 0) { // 取不到总时长，则认为是直播流，不显示播放时间和进度条
        self.progressSld.hidden = true;
//        self.curPosLbl.hidden = true;
        self.curPosLbl.text = @"实时直播";
    }else{
        self.progressSld.hidden = false;
        self.curPosLbl.hidden = false;
        mSyncSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/3 target:self selector:@selector(syncSliderUIStatus) userInfo:nil repeats:YES];
    }
    
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
	[self quicklyStopMovie];
    NSURL *url = [self getNextMediaUrl];
    [self quicklyPlayMovie:url title:nil];
    if (url) {  // 移动列表选中的状态至下一行
        self.epg.selectedIndexPath = [NSIndexPath indexPathForRow:self.epg.selectedIndexPath.row+1 inSection:self.epg.selectedIndexPath.section];
        [self.epg changeSelectedRowState];
    }
    
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
	player.autoSwitchDecodingScheme = false;
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
		self.startPause.selected = false;
		[self startActivityWithMsg:@"缓冲中... 0%"];
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg
{
	if (!self.bubbleMsgLbl.hidden) {
		self.bubbleMsgLbl.text = [NSString stringWithFormat:@"缓冲中... %d%%",
								  [((NSNumber *)arg) intValue]];
	}
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
	if (![Utilities isLocalMedia:self.videoURL]) {
		[player start];
		self.startPause.selected = true;
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
    if (url == nil) {
        return;
    }
	[UIApplication sharedApplication].idleTimerDisabled = YES;// 禁止系统自动关闭屏幕
    [self setBtnEnableStatus:NO];
    self.startPause.selected = false;   // 暂停状态，显示播放按钮
    self.fullHalf.selected = false;  // 半屏状态，显示全屏按钮
    
    [mMPayer setDataSource:url header:nil];
    
//    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:0];
//    NSMutableArray *vals = [NSMutableArray arrayWithCapacity:0];
//    keys[0] = @"-rtmp_live";
//    vals[0] = @"-1";
//    [mMPayer setOptionsWithKeys:keys withValues:vals];
    
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
    mDuration = 0;
	mCurPostion = 0;
	self.progressSld.value = 0.0;
	self.progressSld.segments = nil;
	self.curPosLbl.text = [self getCurrentProgressLabel:0]; //@"00:00:00";
	self.downloadRate.text = nil;
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
		self.startPause.selected = false;
	} else {
		[mMPayer start];
		self.startPause.selected = true;
	}
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchCtrlState) object:nil];
    [self performSelector:@selector(switchCtrlState) withObject:nil afterDelay:5.0f];
}

-(IBAction)fullHalfButtonAction:(id)sender{
    if (!self.fullHalf.selected) {  // 当前半屏状态，切换到全屏状态
        [self.backView removeFromSuperview];
        [self.view addSubview:self.backView];
        
        [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:.5f animations:^{
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, App_Height/2-self.backView.center.y);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            transform = CGAffineTransformScale(transform, App_Height/self.backView.bounds.size.width, 320/self.backView.bounds.size.height);
            self.backView.transform = transform;
        } completion:^(BOOL finished) {

        }];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
        [UIView animateWithDuration:.5f animations:^{
            self.backView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.backView removeFromSuperview];
            [self.mainView insertSubview:self.backView belowSubview:self.navigationView];
        }];
    }
    NSLog(@"NAL 1NBV &&&& backview.frame=%@", NSStringFromCGRect(self.backView.frame));
    self.fullHalf.selected = !self.fullHalf.selected;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchCtrlState) object:nil];
    [self performSelector:@selector(switchCtrlState) withObject:nil afterDelay:5.0f];
	
}

-(IBAction)progressSliderDownAction:(id)sender
{
	self.progressDragging = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchCtrlState) object:nil];
}

-(IBAction)progressSliderUpAction:(id)sender
{
	UISlider *sld = (UISlider *)sender;
	[self startActivityWithMsg:@"加载中..."];
	[mMPayer seekTo:(long)(sld.value * mDuration)];
    [self performSelector:@selector(switchCtrlState) withObject:nil afterDelay:5.0f];
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
	[self startActivityWithMsg:@"加载中..."];
    [mMPayer seekTo:seek];
    // 做任何工具栏的操作都重新进行自动隐藏的计时
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchCtrlState) object:nil];
    [self performSelector:@selector(switchCtrlState) withObject:nil afterDelay:5.0f];
}

#pragma mark - Sync UI Status

-(void)syncSliderUIStatus
{
	if (!self.progressDragging) {
		mCurPostion  = [mMPayer getCurrentPosition];
		[self.progressSld setValue:(float)mCurPostion/mDuration];
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
	self.fullHalf.enabled = enable;
}

-(void)switchCtrlState{
    isCtrlHide = !isCtrlHide;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.controlBackground.alpha = isCtrlHide?0:1;
        self.progressSld.alpha = isCtrlHide?0:1;
        self.curPosLbl.alpha = isCtrlHide?0:1;
        self.startPause.alpha = isCtrlHide?0:1;
        self.fullHalf.alpha = isCtrlHide?0:1;
        self.downloadRate.alpha = isCtrlHide?0:1;
    }];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchCtrlState) object:nil];
    if ( !isCtrlHide ) {
        // 每次显示工具栏后都在n秒后自动隐藏
        [self performSelector:@selector(switchCtrlState) withObject:nil afterDelay:5.0f];
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
	NSString *sError = @"视频无法播放";
	NSString *sReason = @"加载错误";
	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   sError, NSLocalizedDescriptionKey,
							   sReason, NSLocalizedFailureReasonErrorKey,
							   nil];
	NSError *error = [NSError errorWithDomain:@"Vitamio" code:0 userInfo:errorDict];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"确定"
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

- (NSURL *)getCurrMediaURL{

    NSURL *url=[NSURL URLWithString:[self.videoModel.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSString *m3u8 = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"m3u8 content:%@",m3u8);
    return url;
    
    // 以下为测试地址
//    return [NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sohu.m3u8"]];
//    return [NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ytv.m3u8"]];
//    return [NSURL URLWithString:@"http://hot.vrs.sohu.com/ipad1407291_4596271359934_4618512.m3u8"];
//    return [NSURL URLWithString:@"http://live1.av.jiaodong.net/channels/yttv/video_yt1/m3u8:500k/1400430735000,1400430855000,120000"];// YTV-1糖果剧
//    return [NSURL URLWithString:@"http://cibn1.vdnplus.com/channels/tvie/CCTV-1/m3u8:sd/1400433840000,1400435880000,2040000"];// CCTV-1动物世界
//    return [NSURL URLWithString:@"http://vod.av.jiaodong.net/vod_storage/vol1/2014/03/19/5328fce906a83/01b70087af0c11e3a5fa848f69e075fe.mp4"];
//    return [NSURL URLWithString:@"http://live1.av.jiaodong.net/channels/yttv/video_yt1/m3u8:500k/1398129434000,1398129438000,5000"];
}

- (void) onVideoChanged:(JDOVideoEPGModel *)epgModel withDayEpg:(NSArray *)epgList{
    self.currentEpgModel = epgModel;
    self.currentEpgList = epgList;
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

- (NSURL *)getNextMediaUrl{
    BOOL isLast = true;
    for (int i = 0; i<self.currentEpgList.count-1; i++) {
        JDOVideoEPGModel *epg = self.currentEpgList[i];
        if (self.currentEpgModel == epg) {
            self.currentEpgModel = self.currentEpgList[i+1];
            isLast = false;
            break;
        }
    }
    // 若找不到则说明播放的是当天的最后一档节目
    if (isLast) {
        return nil;
    }
    
#warning 未考虑在播放的时候节目单已经过期的情况，即当前播放的节目已经不是节目单正在播放指向的那一个
    NSURL *url;
    if(self.currentEpgModel.state == JDOVideoStatePlayback){
        long startTime = [NSNumber numberWithDouble:[self.currentEpgModel.start_time timeIntervalSince1970]].longValue;
        long endTime = [NSNumber numberWithDouble:[self.currentEpgModel.end_time timeIntervalSince1970]].longValue;
        url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/%ld000,%ld000,5000",self.videoModel.liveUrl,startTime,endTime] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else if(self.currentEpgModel.state == JDOVideoStateLive){
        url = [NSURL URLWithString:[self.videoModel.liveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
	return url;
}


@end

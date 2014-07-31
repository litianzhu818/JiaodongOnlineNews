//
//  JDOAudioPlayController.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-11.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOAudioPlayController.h"
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

#define Player_Height 43

#define Dept_Label_Tag 101
#define Title_Label_Tag 102
#define Subtitle_Label_Tag 103
#define Secret_Field_Tag 104

#define Content_Font_Size 16.0f
#define Subtitle_Font_Size 14.0f
#define kBackviewDefaultRect		CGRectMake(0, 47, 280, 180)


@interface JDOAudioPlayController ()
{
    VMediaPlayer       *mMPayer;
    long               mDuration;
    long               mCurPostion;
    NSTimer            *mSyncSeekTimer;
}

@property (strong, nonatomic) UITapGestureRecognizer *closeReviewGesture;
@property (strong, nonatomic) UIView *blackMask;

@property (nonatomic, strong) UIButton *startPause;
@property (nonatomic, strong) VSegmentSlider *progressSld;
@property (nonatomic, strong) UILabel  *curPosLbl;
@property (nonatomic, strong) UILabel  *bubbleMsgLbl;
@property (nonatomic, strong) UILabel  *downloadRate;
@property (nonatomic, strong) UIView  	*activityCarrier;
@property (nonatomic, strong) UIImageView  	*backView;
@property (nonatomic, strong) UIView  	*carrier;

@property (nonatomic, copy)   NSURL *videoURL;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL progressDragging;

@property (nonatomic, strong) JDOVideoEPGModel *currentEpgModel;
@property (nonatomic, strong) NSArray *currentEpgList;

@end

@implementation JDOAudioPlayController

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
        self.backView.hidden = false;
        self.audioEpg.hidden = false;
        self.toolbar.hidden = false;
    }else{
        self.backView.hidden = true;
        self.audioEpg.hidden = true;
        self.toolbar.hidden = true;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
    
    _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, App_Height-44-Player_Height, 320, Player_Height)];
    _backView.image = [UIImage imageNamed:@"video_player_background"];
    _backView.userInteractionEnabled = true;
    [self.view addSubview:_backView];
    
//    _activityCarrier = [[UIView alloc] initWithFrame:CGRectMake(10, 5, Player_Height-10, Player_Height-10)];
//    [self.view addSubview:_activityCarrier];
    
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                         UIActivityIndicatorViewStyleWhite];
    _activityView.frame = CGRectMake(320-10-30, 8, Player_Height-10, Player_Height-10);
	[self.backView addSubview:self.activityView];
    
    _progressSld = [[VSegmentSlider alloc] initWithFrame:CGRectMake(-2, -7, 324, 29)];
    [_progressSld addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchCancel];
    [_progressSld addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [_progressSld addTarget:self action:@selector(progressSliderDownAction:) forControlEvents:UIControlEventTouchDown];
    [_progressSld addTarget:self action:@selector(dragProgressSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.backView addSubview:self.progressSld];
    
	UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(progressSliderTapped:)];
    [self.progressSld addGestureRecognizer:gr];
    [self.progressSld setThumbImage:[UIImage imageNamed:@"video_seekbar_btn"] forState:UIControlStateNormal];
    [self.progressSld setMinimumTrackImage:[UIImage imageNamed:@"video_seekbar_front"] forState:UIControlStateNormal];
    [self.progressSld setMaximumTrackImage:[UIImage imageNamed:@"video_seekbar_back"] forState:UIControlStateNormal];
    self.progressSld.hidden = true;
    
    _startPause = [UIButton buttonWithType:UIButtonTypeCustom];
    _startPause.frame = CGRectMake(151, 14, 22, 22);
    [_startPause addTarget:self action:@selector(startPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_startPause setImage:[UIImage imageNamed:@"video_player_play" ] forState:UIControlStateNormal];
    [_startPause setImage:[UIImage imageNamed:@"video_player_stop" ] forState:UIControlStateSelected];
    [self.backView addSubview:self.startPause];
    
    _curPosLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 109, 21)];
    _curPosLbl.textColor = [UIColor whiteColor];
    _curPosLbl.font = [UIFont systemFontOfSize:12];
    [self.backView addSubview:self.curPosLbl];
    
    _downloadRate = [[UILabel alloc] initWithFrame:CGRectMake(218, 14, 52, 21)];
    _downloadRate.textColor = [UIColor whiteColor];
    _downloadRate.font = [UIFont systemFontOfSize:12];
    [self.backView addSubview:self.downloadRate];
    
	if (!mMPayer) {
		mMPayer = [VMediaPlayer sharedInstance];
		[mMPayer setupPlayerWithCarrierView:self.backView withDelegate:self];
		[self setupObservers];
	}
    
    CGRect fullFrame = CGRectMake(0, (Is_iOS7?64:44), 320, App_Height-(Is_iOS7?64:44)-Player_Height-44+6/*工具栏*//*进度条上方透明*/);
    self.audioEpg = [[JDOVideoEPG alloc] initWithFoldFrame:CGRectZero fullFrame:fullFrame model:self.videoModel delegate:self fold:true];
    [self.audioEpg setBackground:@"audio_play_background"];
    [self.view insertSubview:self.audioEpg belowSubview:self.backView];
    
    
    NSArray *toolbarBtnConfig = @[[NSNumber numberWithInt:ToolBarButtonReview],[NSNumber numberWithInt:ToolBarButtonShare]];
    // 使用专门定义的一条新闻id作为评论的入口
    self.videoModel.id = @"31318";
    _toolbar = [[JDOToolBar alloc] initWithModel:self.videoModel parentController:self typeConfig:toolbarBtnConfig widthConfig:nil frame:CGRectMake(0, App_Height-56.0, 320, 56.0) theme:ToolBarThemeWhite];
    _toolbar.shareTarget = self;
    [self.view addSubview:_toolbar];
    
    self.closeReviewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.toolbar action:@selector(hideReviewView)];
    self.blackMask = [self.view blackMask];
    [_blackMask addGestureRecognizer:self.closeReviewGesture];
    
    // 加载视频
    [self quicklyPlayMovie:[self getCurrMediaURL] title:nil];
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
	[self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
    [self resignFirstResponder];
}

- (void)dealloc{
	[self unSetupObservers];
}


#pragma mark - Respond to the Remote Control Events

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)applicationDidEnterForeground:(NSNotification *)notification
{
//	[mMPayer setVideoShown:YES];
//    if (![mMPayer isPlaying]) {
//		[mMPayer start];
//		self.startPause.selected = true;
//	}
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
//    if ([mMPayer isPlaying]) {
//		[mMPayer pause];
//		[mMPayer setVideoShown:NO];
//    }
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
    JDOCenterViewController *centerViewController = (JDOCenterViewController *)self.navigationController;
    JDOReviewListController *reviewController = [[JDOReviewListController alloc] initWithType:JDOReviewTypeNews params:@{@"aid":self.videoModel.id,@"deviceId":JDOGetUUID()}];
    reviewController.model = self.videoModel;
    [centerViewController pushViewController:reviewController animated:true];
}

- (void)loadDataFromNetwork{
    [self setCurrentState:ViewStatusNormal];
}


#pragma mark VMediaPlayerDelegate Implement / Required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    [player setVideoFillMode:VMVideoFillModeStretch];
    [player start];
    
	[self setBtnEnableStatus:YES];
    self.startPause.selected = true; // 暂停
	[self stopActivity];
    
    mDuration = [player getDuration];
    if (mDuration == 0) { // 取不到总时长，则认为是直播流，不显示播放时间和进度条
        self.progressSld.hidden = true;
        self.curPosLbl.text = @"实时广播";
    }else{
        self.progressSld.hidden = false;
        self.curPosLbl.hidden = false;
        mSyncSeekTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/3 target:self selector:@selector(syncSliderUIStatus) userInfo:nil repeats:YES];
    }
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
	[self quicklyStopMovie];
    [self quicklyPlayMovie:[self getNextMediaUrl] title:nil];
    // 移动列表选中的状态至下一行
    self.audioEpg.selectedIndexPath = [NSIndexPath indexPathForRow:self.audioEpg.selectedIndexPath.row+1 inSection:self.audioEpg.selectedIndexPath.section];
    [self.audioEpg changeSelectedRowState];
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
	[UIApplication sharedApplication].idleTimerDisabled = YES;// 禁止系统自动关闭屏幕
    [self setBtnEnableStatus:NO];
    self.startPause.selected = false;   // 暂停状态，显示播放按钮
    
    [mMPayer setDataSource:url header:nil];
    
    [mMPayer prepareAsync];
	[self startActivityWithMsg:@"正在加载..."];
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

-(void)goBackButtonAction:(id)sender
{
	[self quicklyStopMovie];
}

-(void)startPauseButtonAction:(id)sender
{
	BOOL isPlaying = [mMPayer isPlaying];
	if (isPlaying) {
		[mMPayer pause];
		self.startPause.selected = false;
	} else {
		[mMPayer start];
		self.startPause.selected = true;
	}
}

-(void)progressSliderDownAction:(id)sender
{
	self.progressDragging = YES;
}

-(void)progressSliderUpAction:(id)sender
{
	UISlider *sld = (UISlider *)sender;
	[self startActivityWithMsg:@"加载中..."];
	[mMPayer seekTo:(long)(sld.value * mDuration)];
}

-(void)dragProgressSliderAction:(id)sender
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
	NSString *sError = @"音频无法播放";
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
    return url;
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
    for (int i = 0; i<self.currentEpgList.count-1; i++) {
        JDOVideoEPGModel *epg = self.currentEpgList[i];
        if (self.currentEpgModel == epg) {
            self.currentEpgModel = self.currentEpgList[i+1];
            break;
        }
    }
    // 若找不到则说明播放的是当天的最后一档节目，那么重复播放当前节目
    
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

//
//  JDOVideoLiveCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-4-18.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOVideoLiveCell.h"
#import "JDOVideoModel.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"
#import "JDOVideoEPGModel.h"
#import "VMediaExtracter.h"

#define Left_Margin 7.5f
#define Right_Margin 7.5f
#define Top_Margin 7.5f
#define Bottom_Margin 10.0f
#define Padding 7.5f
#define Image_Width 72.0f
#define Image_Height (News_Cell_Height-Top_Margin-Bottom_Margin)

@interface JDOVideoLiveCell ()

@property (nonatomic,assign) int rowIndex;

@end

@implementation JDOVideoLiveCell{

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier models:(NSArray *)models
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.models = models;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];

        UIImageView *leftItemView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7.5, 145, 151)];
        leftItemView.tag = 1001;
        [self initItemView:leftItemView];
        [self.contentView addSubview:leftItemView];
        
        UIImageView *rightItemView = [[UIImageView alloc] initWithFrame:CGRectMake(10+145+10, 7.5, 145, 151)];
        rightItemView.tag = 1002;
        [self initItemView:rightItemView];
        [self.contentView addSubview:rightItemView];
    }
    return self;
}


- (void)setContentAtIndex:(NSInteger) index{
    self.rowIndex = index;
    UIImageView *leftItemView = (UIImageView *)[self.contentView viewWithTag:1001];
    UIImageView *rightItemView = (UIImageView *)[self.contentView viewWithTag:1002];
    
    int modelIndex = 2*index;
    JDOVideoModel *leftItemModel = (JDOVideoModel *)self.models[modelIndex];
    [self fillItemView:leftItemView withModel:leftItemModel];
    
    modelIndex = 2*index+1;
    if( self.models.count > modelIndex ){
        rightItemView.hidden = false;
        JDOVideoModel *rightItemModel = (JDOVideoModel *)self.models[modelIndex];
        [self fillItemView:rightItemView withModel:rightItemModel];
    }else{
        rightItemView.hidden = true;
    }
}

- (void) fillItemView:(UIImageView *)itemView withModel:(JDOVideoModel *)itemModel {
    itemModel.observer = self;
 
    UIImageView *logoView = (UIImageView *)[itemView viewWithTag:101];
    __block UIImageView *blockLogoView = logoView;
    [logoView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:itemModel.logo]] success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            [blockLogoView.layer addAnimation:[self createNewTransition] forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    
    UIImageView *frameView = (UIImageView *)[itemView viewWithTag:102];
    if (itemModel.currentFrame != nil) {    // 关键帧已经加载完成，比如初始化时不可见的行，在显示的时候可能已经加载完
        frameView.image = itemModel.currentFrame.frameImage;
        [frameView.layer addAnimation:[self createNewTransition] forKey:nil];
    }
    [itemModel addObserver:self forKeyPath:@"currentFrame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    UILabel *epgLabel = (UILabel *)[itemView viewWithTag:103];
    if (itemModel.currentProgram != nil) {
        epgLabel.text = itemModel.currentProgram;
    }
    [itemModel addObserver:self forKeyPath:@"currentProgram" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

}

- (void) initItemView:(UIImageView *)itemView {
    itemView.userInteractionEnabled = true;
    itemView.image = [UIImage imageNamed:@"video_channel_background"];
    
    // 频道logo
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 145, 30)];
    logoView.tag = 101;
    [itemView addSubview:logoView];
    
    // 当前视频第一帧
    UIImageView *frameView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 151-116-5, 145-2*5, 116)];
    frameView.tag = 102;
    [itemView addSubview:frameView];
    
    // 当前节目
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 151-24-5, CGRectGetWidth(frameView.frame), 24)];
    backgroundView.image = [UIImage imageNamed:@"video_epg_background"];
    [itemView addSubview:backgroundView];
    
    UILabel *epgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5+5, 151-24-5, CGRectGetWidth(frameView.frame)-10, 24) ];
    epgLabel.tag = 103;
    epgLabel.text = @"加载中...";
    epgLabel.font = [UIFont boldSystemFontOfSize:13];
    epgLabel.textColor = [UIColor whiteColor];
    epgLabel.backgroundColor = [UIColor clearColor];
    [itemView addSubview:epgLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onItemClick:)];
    [itemView addGestureRecognizer:tap];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    JDOVideoModel *model = (JDOVideoModel *)object;
    UIImageView *itemView;
    int modelIndex = [self.models indexOfObject:model];
    if (modelIndex%2 == 0){
        itemView = (UIImageView *)[self.contentView viewWithTag:1001];
    }else{
        itemView = (UIImageView *)[self.contentView viewWithTag:1002];
    }
    
    if ([keyPath isEqualToString:@"currentProgram"]) {
        UILabel *epgLabel = (UILabel *)[itemView viewWithTag:103];
        NSString *currentProgram = change[NSKeyValueChangeNewKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            epgLabel.text = currentProgram;
        });
    }else if([keyPath isEqualToString:@"currentFrame"]) {
        UIImageView *frameView = (UIImageView *)[itemView viewWithTag:102];
        JDOVideoFrame *currentFrame = change[NSKeyValueChangeNewKey];
        dispatch_async(dispatch_get_main_queue(), ^{    // 不在主线程执行会卡住UI，导致全部加载完成后才会刷新和操作
            frameView.image = currentFrame.frameImage;
            [frameView.layer addAnimation:[self createNewTransition] forKey:nil];
        });
    }
}

- (CATransition *)createNewTransition{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    return transition;
}

- (void)onItemClick:(UITapGestureRecognizer *)gesture{
    int modelIndex = 0;
    if (gesture.view.tag == 1001){  // 左侧item
        modelIndex = self.rowIndex*2;
    }else if(gesture.view.tag == 1002){
        modelIndex = self.rowIndex*2+1;
    }
    JDOVideoModel *model = self.models[modelIndex];
    if (model.currentFrame == nil || !model.currentFrame.success ) {
        return;
    }
    [self.delegate onLiveChannelClick:model];
}

@end

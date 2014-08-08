//
//  JDOOnDemandCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOOnDemandCell.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"
#import "JDOVideoEPGModel.h"
#import "VMediaExtracter.h"
#import "JDOVideoChannelModel.h"
#import "JDOOnDemandController.h"

#define Left_Margin 8.5f
#define Right_Margin 8.5f
#define Top_Margin 15.0f
#define Bottom_Margin 0
#define Padding 6.0f
#define Image_Width 97.0f
#define Image_Height 86.5f

@interface JDOOnDemandCell ()

@property (nonatomic,assign) int rowIndex;

@end

@implementation JDOOnDemandCell{
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier models:(NSArray *)models
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.models = models;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *leftItemView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin, Top_Margin, Image_Width, Image_Height)];
        leftItemView.tag = 1001;
        [self initItemView:leftItemView];
        [self.contentView addSubview:leftItemView];
        
        UIImageView *centerItemView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin+Image_Width+Padding, Top_Margin, Image_Width, Image_Height)];
        centerItemView.tag = 1002;
        [self initItemView:centerItemView];
        [self.contentView addSubview:centerItemView];
        
        UIImageView *rightItemView = [[UIImageView alloc] initWithFrame:CGRectMake(Left_Margin+2*Image_Width+2*Padding, Top_Margin, Image_Width, Image_Height)];
        rightItemView.tag = 1003;
        [self initItemView:rightItemView];
        [self.contentView addSubview:rightItemView];
    }
    return self;
}


- (void)setContentAtIndex:(NSInteger) index{
    self.rowIndex = index;
    UIImageView *leftItemView = (UIImageView *)[self.contentView viewWithTag:1001];
    UIImageView *centerItemView = (UIImageView *)[self.contentView viewWithTag:1002];
    UIImageView *rightItemView = (UIImageView *)[self.contentView viewWithTag:1003];
    
    int modelIndex = 3*index;
    JDOVideoChannelModel *leftItemModel = (JDOVideoChannelModel *)self.models[modelIndex];
    [self fillItemView:leftItemView withModel:leftItemModel];
    
    modelIndex = 3*index+1;
    if( self.models.count > modelIndex ){
        centerItemView.hidden = false;
        JDOVideoChannelModel *centerItemModel = (JDOVideoChannelModel *)self.models[modelIndex];
        [self fillItemView:centerItemView withModel:centerItemModel];
    }else{
        centerItemView.hidden = true;
    }
    
    modelIndex = 3*index+2;
    if( self.models.count > modelIndex ){
        rightItemView.hidden = false;
        JDOVideoChannelModel *rightItemModel = (JDOVideoChannelModel *)self.models[modelIndex];
        [self fillItemView:rightItemView withModel:rightItemModel];
    }else{
        rightItemView.hidden = true;
    }
}

- (void) fillItemView:(UIImageView *)itemView withModel:(JDOVideoChannelModel *)itemModel {
    
    UIImageView *iconView = (UIImageView *)[itemView viewWithTag:101];
    __block UIImageView *blockIconView = iconView;
    [iconView setImageWithURL:[NSURL URLWithString:[itemModel.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            [blockIconView.layer addAnimation:[self createNewTransition] forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    
    UILabel *epgLabel = (UILabel *)[itemView viewWithTag:102];
    epgLabel.text = itemModel.title;
    
}

- (void) initItemView:(UIImageView *)itemView {
    itemView.userInteractionEnabled = true;
    itemView.image = [UIImage imageNamed:@"video_ondemond_background"];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(1.5, 1, Image_Width-3, 63)];
    iconView.tag = 101;
    [itemView addSubview:iconView];
    
    UILabel *epgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 70, Image_Width-10, Image_Height-70) ];
    epgLabel.tag = 102;
    epgLabel.text = @"加载中...";
    epgLabel.textAlignment = NSTextAlignmentCenter;
    epgLabel.font = [UIFont boldSystemFontOfSize:13];
    epgLabel.textColor = [UIColor colorWithHex:Gray_Color_Type2];
    epgLabel.backgroundColor = [UIColor clearColor];
    [itemView addSubview:epgLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onItemClick:)];
    [itemView addGestureRecognizer:tap];
    
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
        modelIndex = self.rowIndex*3;
    }else if(gesture.view.tag == 1002){
        modelIndex = self.rowIndex*3+1;
    }else if(gesture.view.tag == 1003){
        modelIndex = self.rowIndex*3+2;
    }
    JDOVideoChannelModel *model = self.models[modelIndex];
    
    JDOOnDemandController *controller = [[JDOOnDemandController alloc] initWithModel:model];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:controller animated:true];
}

@end

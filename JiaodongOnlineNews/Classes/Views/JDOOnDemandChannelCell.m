//
//  JDOOnDemandChannelCell.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-7-16.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOOnDemandChannelCell.h"
#import "DCKeyValueObjectMapping.h"
#import "DCParserConfiguration.h"
#import "VMediaExtracter.h"
#import "JDOVideoOnDemandModel.h"
#import "JDOOnDemandPlayController.h"

#define Left_Margin 18.5f
#define Right_Margin 18.5f
#define Top_Margin 15.0f
#define Bottom_Margin 0
#define Padding 18.5f
#define Image_Width 82.0f
#define Image_Height 86.5f

@interface JDOOnDemandChannelCell ()

@property (nonatomic,assign) int rowIndex;

@end

@implementation JDOOnDemandChannelCell{
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *leftItemView = [[UIView alloc] initWithFrame:CGRectMake(Left_Margin, Top_Margin, Image_Width, Image_Height)];
        leftItemView.tag = 1001;
        [self initItemView:leftItemView];
        [self.contentView addSubview:leftItemView];
        
        UIView *centerItemView = [[UIView alloc] initWithFrame:CGRectMake(Left_Margin+Image_Width+Padding, Top_Margin, Image_Width, Image_Height)];
        centerItemView.tag = 1002;
        [self initItemView:centerItemView];
        [self.contentView addSubview:centerItemView];
        
        UIView *rightItemView = [[UIView alloc] initWithFrame:CGRectMake(Left_Margin+2*Image_Width+2*Padding, Top_Margin, Image_Width, Image_Height)];
        rightItemView.tag = 1003;
        [self initItemView:rightItemView];
        [self.contentView addSubview:rightItemView];
    }
    return self;
}


- (void)setContentAtIndex:(NSInteger) index map:(NSDictionary *)dayMap key:(NSArray *)dayKey{
    self.rowIndex = index;
    self.dayKey = dayKey;
    self.dayMap = dayMap;
    
    UIView *leftItemView = (UIView *)[self.contentView viewWithTag:1001];
    UIView *centerItemView = (UIView *)[self.contentView viewWithTag:1002];
    UIView *rightItemView = (UIView *)[self.contentView viewWithTag:1003];
    
    int nrdDate = 3*index; // 所有数据里的第几天的
    NSString *day = [dayKey objectAtIndex:nrdDate];
    JDOVideoOnDemandModel *leftItemModel = (JDOVideoOnDemandModel *)[[dayMap objectForKey:day] objectAtIndex:0];
    [self fillItemView:leftItemView withModel:leftItemModel];
    
    nrdDate = 3*index+1;
    if( dayKey.count > nrdDate ){
        centerItemView.hidden = false;
        day = [dayKey objectAtIndex:nrdDate];
        JDOVideoOnDemandModel *centerItemModel = (JDOVideoOnDemandModel *)[[dayMap objectForKey:day] objectAtIndex:0];
        [self fillItemView:centerItemView withModel:centerItemModel];
    }else{
        centerItemView.hidden = true;
    }
    
    nrdDate = 3*index+2;
    if( dayKey.count > nrdDate ){
        rightItemView.hidden = false;
        day = [dayKey objectAtIndex:nrdDate];
        JDOVideoOnDemandModel *rightItemModel = (JDOVideoOnDemandModel *)[[dayMap objectForKey:day] objectAtIndex:0];
        [self fillItemView:rightItemView withModel:rightItemModel];
    }else{
        rightItemView.hidden = true;
    }
}

- (void) fillItemView:(UIView *)itemView withModel:(JDOVideoOnDemandModel *)itemModel {
    
    UIImageView *iconView = (UIImageView *)[itemView viewWithTag:101];
    __block UIImageView *blockIconView = iconView;
    [iconView setImageWithURL:[NSURL URLWithString:[itemModel.pic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] success:^(UIImage *image, BOOL cached) {
        if(!cached){    // 非缓存加载时使用渐变动画
            [blockIconView.layer addAnimation:[self createNewTransition] forKey:nil];
        }
    } failure:^(NSError *error) {
        
    }];
    
    UILabel *epgLabel = (UILabel *)[itemView viewWithTag:102];
    epgLabel.text = [itemModel.pubdate substringWithRange:NSMakeRange(0, 10)];
    
}

- (void) initItemView:(UIView *)itemView {
    
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
    NSString *day = self.dayKey[modelIndex];
    NSArray *dayArray = [self.dayMap objectForKey:day];
    
    JDOOnDemandPlayController *controller = [[JDOOnDemandPlayController alloc] initWithModels:dayArray];
    JDOCenterViewController *centerController = (JDOCenterViewController *)[[SharedAppDelegate deckController] centerController];
    [centerController pushViewController:controller animated:true];
}

@end

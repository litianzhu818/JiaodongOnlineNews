//
//  JDOChannelItem.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-1-17.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#define section2startY 170

typedef enum {
    ChannelItemSectionSelected = 0,
	ChannelItemSectionUnselected
} ChannelItemSection;

@class JDOChannelItem;

@protocol JDOChannelItemDelegate

//- (void)arrangeUpButtonsWithButton:(UIDragButton *)button andAdd:(BOOL)_bool;
//- (void)arrangeDownButtonsWithButton:(UIDragButton *)button andAdd:(BOOL)_bool;
//- (void)setDownButtonsFrameWithAnimate:(BOOL)_bool withoutShakingButton:(UIDragButton *)shakingButton;
- (void)checkOthersWithButton:(JDOChannelItem *)shakingButton;
//- (void)removeShakingButton:(UIDragButton *)button fromUpButtons:(BOOL)_bool;

@end

@interface JDOChannelItem : UIButton
{
    CGPoint lastPoint;
    NSTimer *timer;
}

@property (nonatomic, strong) NSDictionary *model;
@property (nonatomic, assign) ChannelItemSection section;
@property (nonatomic, assign) int pos;
@property (nonatomic, assign) CGPoint lastCenter;
@property (nonatomic, assign) id<JDOChannelItemDelegate> delegate;

- (id)initWithModel:(NSDictionary *)model;
- (void)refreshFrameWithPos:(int)pos;
- (void)setSubstituteWithPos:(int)pos;
- (void)startShake;
- (void)stopShake;

@end
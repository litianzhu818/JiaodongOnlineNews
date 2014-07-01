//
//  JDOChannelSetting.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-1-15.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOChannelSetting.h"

@implementation JDOChannelSetting {
    NSMutableArray *selectedItems;
    NSMutableArray *unselectedItems;
    NSMutableArray *selectedModels;
    NSMutableArray *unselectedModels;
    bool isMoving;
    bool isAnimating;
    bool isChanged;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        
        UIImageView *section0 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 34.5)];
        section0.image = [UIImage imageNamed:@"channel_section0"];
        [self addSubview:section0];
        UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBtn.frame = CGRectMake(275, 7, 35, 20);
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [finishBtn setTitleColor:[UIColor colorWithHex:@"0053a1"] forState:UIControlStateNormal];
        [finishBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [finishBtn setBackgroundColor:[UIColor clearColor]];
        [finishBtn addTarget:self action:@selector(onFinished) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:finishBtn];
        UIImageView *section1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, section2startY, 320, 34.5)];
        section1.image = [UIImage imageNamed:@"channel_section1"];
        [self addSubview:section1];
        
        isMoving=false;
        isAnimating=false;
        isChanged=false;
        
        selectedItems = [NSMutableArray array];
        unselectedItems = [NSMutableArray array];
        selectedModels = [NSMutableArray array];
        unselectedModels = [NSMutableArray array];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *channelList = [userDefault objectForKey:@"channel_list"];
        for (int i=0; i<channelList.count; i++) {
            NSDictionary *channel = [channelList objectAtIndex:i];
            BOOL isShow = [[channel objectForKey:@"isShow"] boolValue];
            if (isShow) {
                [selectedModels addObject:channel];
            }else{
                [unselectedModels addObject:channel];
            }
        }
        
#warning 设置前两项不允许删除和移动(烟台、要闻)，但并不能保证前两项从服务器获得的一定是这两个
        int disableIndex = 1;
        for(int i=0; i<selectedModels.count; i++){
            JDOChannelItem *item = [[JDOChannelItem alloc] initWithModel:[selectedModels objectAtIndex:i]];
            [item setSection:ChannelItemSectionSelected];
            [item refreshFrameWithPos:i];
            [item setDelegate:self];
            if (i <= disableIndex) {   // "烟台"栏目不能移动也不能删除，包括:1.不响应单击 2.不响应长按 3.不响应排序
                item.enabled = false;
                [item setBackgroundImage:nil forState:UIControlStateNormal];
                [item setTitleColor:[UIColor colorWithHex:@"969696"] forState:UIControlStateNormal];
            }
            [item addTarget:self action:@selector(addOrDelete:) forControlEvents:UIControlEventTouchUpInside];
            [selectedItems addObject:item];
            [self addSubview:item];
        }
        
        for(int i=0; i<unselectedModels.count; i++){
            JDOChannelItem *item=[[JDOChannelItem alloc] initWithModel:[unselectedModels objectAtIndex:i]];
            [item setSection:ChannelItemSectionUnselected];
            [item refreshFrameWithPos:i];
            [item setDelegate:self];
            [item addTarget:self action:@selector(addOrDelete:) forControlEvents:UIControlEventTouchUpInside];
            [unselectedItems addObject:item];
            [self addSubview:item];
        }
    }
    return self;
}

- (void)onFinished{
    // 保存栏目
    NSMutableArray *channelList = [NSMutableArray array];
    for (int i=0; i<selectedItems.count; i++) {
        JDOChannelItem *item = [selectedItems objectAtIndex:i];
        NSMutableDictionary *model = [item.model mutableCopy];
        [model setObject:[NSNumber numberWithBool:true] forKey:@"isShow"];
        [channelList addObject:model];
    }
    for (int i=0; i<unselectedItems.count; i++) {
        JDOChannelItem *item = [unselectedItems objectAtIndex:i];
        NSMutableDictionary *model = [item.model mutableCopy];
        [model setObject:[NSNumber numberWithBool:false] forKey:@"isShow"];
        [channelList addObject:model];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:channelList forKey:@"channel_list"];
    [userDefault synchronize];
    // 刷新界面和隐藏面板放到delegate的回调中处理
    
    [self.delegate onSettingFinished:isChanged];
    isChanged = false;
}

- (void)addOrDelete:(JDOChannelItem *)sender{
    if(isMoving){
        return;
    }
    isMoving = true;
    isChanged = true;
    if (sender.section == ChannelItemSectionSelected){ //点上方删除的项目
        int oldPos = sender.pos;
        [UIView animateWithDuration:0.4 animations:^{
            // 删除项目移到下方最后
            sender.section = ChannelItemSectionUnselected;
            [sender refreshFrameWithPos:unselectedItems.count];
            // 后方item依次前移
            for (int i=selectedItems.count-1; i>oldPos; i--) {
                [(JDOChannelItem *)[selectedItems objectAtIndex:i] refreshFrameWithPos:i-1];
            }
        } completion:^(BOOL finished) {
            JDOChannelItem *movedItem = [selectedItems objectAtIndex:oldPos];
            [unselectedItems addObject:movedItem];
            [selectedItems removeObjectAtIndex:oldPos];
            isMoving = false;
        }];
    }else if (sender.section == ChannelItemSectionUnselected){ //点下方增加项目
        int oldPos = sender.pos;
        [UIView animateWithDuration:0.4 animations:^{
            // 添加项目移到上方最后
            sender.section = ChannelItemSectionSelected;
            [sender refreshFrameWithPos:selectedItems.count];
            // 后方item依次前移
            for (int i=unselectedItems.count-1; i>oldPos; i--) {
                [(JDOChannelItem *)[unselectedItems objectAtIndex:i] refreshFrameWithPos:i-1];
            }
        } completion:^(BOOL finished) {
            JDOChannelItem *movedItem = [unselectedItems objectAtIndex:oldPos];
            [selectedItems addObject:movedItem];
            [unselectedItems removeObjectAtIndex:oldPos];
            isMoving = false;
        }];
    }
}

- (void)checkOthersWithButton:(JDOChannelItem *)shakingButton{
    if(isAnimating){
        return;
    }
    int oldPos = shakingButton.pos;
    for (int i = 0; i < selectedItems.count; i++) {
        JDOChannelItem *item = (JDOChannelItem *)[selectedItems objectAtIndex:i];
        if (item != shakingButton){
            CGRect intersection = CGRectIntersection(shakingButton.frame, item.frame);
            // 重合面积判断比中心距离判断更合理一些
            if (CGRectGetWidth(intersection)*CGRectGetHeight(intersection)>(72/2 * 31/2) && item.enabled) {
//            float distance = sqrtf(powf(shakingButton.center.x-item.center.x,2) + powf(shakingButton.center.y-item.center.y,2));
//            if(distance < 16){
                [selectedItems removeObjectAtIndex:oldPos];
                [selectedItems insertObject:shakingButton atIndex:i];
                isAnimating = true;
                isChanged = true;
                [UIView animateWithDuration:0.4 animations:^{
                    for(int j=MIN(oldPos, i); j<selectedItems.count; j++){
                        JDOChannelItem *item = [selectedItems objectAtIndex:j];
                        if( item != shakingButton ){
                            [item refreshFrameWithPos:j];
                        }else{
//                            [item setSubstituteWithPos:j];
                            [item setPos:j];
                        }
                    }
                } completion:^(BOOL finished) {
                    [shakingButton setSubstituteWithPos:shakingButton.pos];
                    isAnimating = false;
                }];
                break;
            }
        }
    }
}


@end

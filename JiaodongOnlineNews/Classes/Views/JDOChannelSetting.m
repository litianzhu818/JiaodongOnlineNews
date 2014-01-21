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
    NSMutableArray *selectedTitles;
    NSMutableArray *unselectedTitles;
    bool isMoving;
    bool isAnimating;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:@"F0F0F0"];
        
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
        UIImageView *section1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 150, 320, 34.5)];
        section1.image = [UIImage imageNamed:@"channel_section1"];
        [self addSubview:section1];
        selectedTitles = [NSMutableArray arrayWithObjects:@"烟台",@"要闻",@"社会",@"文体",@"房产",@"汽车", nil];
        unselectedTitles = [NSMutableArray arrayWithObjects:@"理财",@"影讯", nil];
        selectedItems = [NSMutableArray array];
        unselectedItems = [NSMutableArray array];
        
        for(int i=0; i<selectedTitles.count; i++){
            JDOChannelItem *item = [[JDOChannelItem alloc] initWithTitle:selectedTitles[i]];
            [item setSection:ChannelItemSectionSelected];
            [item refreshFrameWithPos:i];
            [item setDelegate:self];
            if (i == 0) {   // "烟台"栏目不能移动也不能删除，包括:1.不响应单击 2.不响应长按 3.不响应排序
                item.enabled = false;
                [item setBackgroundImage:nil forState:UIControlStateNormal];
                [item setTitleColor:[UIColor colorWithHex:@"969696"] forState:UIControlStateNormal];
            }
            [item addTarget:self action:@selector(addOrDelete:) forControlEvents:UIControlEventTouchUpInside];
            [selectedItems addObject:item];
            [self addSubview:item];
        }
        
        for(int i=0; i<unselectedTitles.count; i++){
            JDOChannelItem *item=[[JDOChannelItem alloc] initWithTitle:unselectedTitles[i]];
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
    // 刷新界面
    
    [self.delegate onSettingFinished:self];
}

- (void)addOrDelete:(JDOChannelItem *)sender{
    if(isMoving){
        return;
    }
    isMoving = true;
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
            if (CGRectGetWidth(intersection)*CGRectGetHeight(intersection)>(72/2 * 31/2) && item.enabled) {
//            float distance = sqrtf(powf(shakingButton.center.x-item.center.x,2) + powf(shakingButton.center.y-item.center.y,2));
//            if(distance < 16){
                [selectedItems removeObjectAtIndex:oldPos];
                [selectedItems insertObject:shakingButton atIndex:i];
                isAnimating = true;
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

//
//  JDOAdvCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 14-5-5.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOAdvCell.h"

#define Default_Image @"news_image_placeholder.png"

@implementation JDOAdvCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier datas:(NSArray *)datas
{    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.datas = [[NSArray alloc] initWithArray:datas];
        pageViews = [[NSMutableArray alloc] init];
        currentLayer = 0;
        
        for (int i = 0; i < self.datas.count; i++) {
            NSString *url = [(NSDictionary *)[self.datas objectAtIndex:i] objectForKey:@"mpic"];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, Adv_Cell_Height)];
            [imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:url]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
            } failure:^(NSError *error) {
            }];
            [self addSubview:imageView];
            if (i == 0) {
                [imageView setHidden:NO];
            } else {
                [imageView setHidden:YES];
            }
            [pageViews addObject:imageView];
        }
        if (pageViews.count > 1) {
            [self performSelector:@selector(animationTansition) withObject:nil afterDelay:3.0];
        }
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self performSelector:@selector(animationTansition) withObject:nil afterDelay:3.0];
}

- (void)animationTansition{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 1.0;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    // 设定动画类型
    // @"cube" 立方体  @"oglFlip" 翻转   @"pageCurl" 翻页  @"pageUnCurl" 反翻页
    
    if(currentLayer == pageViews.count-1){
        currentLayer= 0;
    }else{
        currentLayer++;
    }
    [self smallViewChangeToIndex:currentLayer];
    animation.type = @"cube";
    animation.subtype = kCATransitionFromTop;
    [self.layer addAnimation:animation forKey:@"animation"];
}

- (void)smallViewChangeToIndex:(NSInteger)index{
    for(int i=0;i<pageViews.count;i++){
        if (i != index) {
            [(UIView *)[pageViews objectAtIndex:i] setHidden:YES];
        }else{
            [(UIView *)[pageViews objectAtIndex:i] setHidden:NO];
        }
    }
}

- (int)getCurrentLayer
{
    return currentLayer;
}

- (void)setCurrentLayer:(int)current
{
    currentLayer = current;
}

@end

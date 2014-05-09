//
//  JDOAdvCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 14-5-5.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOAdvCell.h"

#define Default_Image @"news_image_placeholder.png"

@implementation JDOAdvCell{
    UIView *animContainter;
    NSMutableArray *pageViews;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        pageViews = [[NSMutableArray alloc] init];
        
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background"]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_content_background_selected"]];
        animContainter = [[UIView alloc] initWithFrame:CGRectMake(7.5,7.5,320-7.5*2, Adv_Cell_Height-7.5*2)];
        [self.contentView addSubview:animContainter];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray{
    self.datas = dataArray;
    _currentPage = 0;
    for (int i = 0; i<pageViews.count; i++) {
        [(UIView *)[pageViews objectAtIndex:i] removeFromSuperview];
    }
    [pageViews removeAllObjects];
    for (int i = 0; i < dataArray.count; i++) {
        NSString *url = [(NSDictionary *)[dataArray objectAtIndex:i] objectForKey:@"mpic"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320-7.5*2, Adv_Cell_Height-7.5*2)];
        __block UIImageView *blockImageView = imageView;
        [imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:url]] placeholderImage:[UIImage imageNamed:@"adv_banner"] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
            if(!cached){    // 非缓存加载时使用渐变动画
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [blockImageView.layer addAnimation:transition forKey:nil];
            }
        } failure:^(NSError *error) {
            
        }];
        [animContainter addSubview:imageView];
        [imageView setHidden:(i!=0)];
        [pageViews addObject:imageView];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationTansition) object:nil ];
    if (pageViews.count > 1) {
        [self performSelector:@selector(animationTansition) withObject:nil afterDelay:3.0];
    }
    
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
    
    if( _currentPage == pageViews.count-1 ){
        _currentPage= 0;
    }else{
        _currentPage++;
    }
    for(int i=0;i<pageViews.count;i++){
        if (i != _currentPage) {
            [(UIView *)[pageViews objectAtIndex:i] setHidden:YES];
        }else{
            [(UIView *)[pageViews objectAtIndex:i] setHidden:NO];
        }
    }
    animation.type = @"cube";
    animation.subtype = kCATransitionFromTop;
    [animContainter.layer addAnimation:animation forKey:@"animation"];
}

@end

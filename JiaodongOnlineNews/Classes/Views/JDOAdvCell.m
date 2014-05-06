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
        currentLayer = 0;
    }
    return self;
}

- (void)addLayer:(NSArray*)params index:(int)index
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    NSString *url = [(NSDictionary *)[self.datas objectAtIndex:index] objectForKey:@"mpic"];
    [imageView setImageWithURL:[NSURL URLWithString:[SERVER_RESOURCE_URL stringByAppendingString:url]] placeholderImage:[UIImage imageNamed:Default_Image] noImage:[JDOCommonUtil ifNoImage] options:SDWebImageOption success:^(UIImage *image, BOOL cached) {
        
    } failure:^(NSError *error) {
        
    }];
    //创建支持渐变背景的CAGradientLayer
    CALayer *gradient = [imageView layer];
    //设置位置，和颜色等参数
    //gradient.contentsScale = [UIScreen mainScreen].scale;
    gradient.bounds = imageView.bounds;
    gradient.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //gradient.colors = @[(id)[UIColor grayColor].CGColor, (id)[UIColor blackColor].CGColor];
    //gradient.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor redColor].CGColor];
    //背景颜色
    //[gradient setBackgroundColor:[UIColor redColor].CGColor];
    //[gradient setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"logo2_with_bg"]].CGColor];
    //gradient.locations = @[@0, @1];
    //gradient.startPoint = CGPointMake(0, 0);
    //gradient.endPoint = CGPointMake(0, 1);
    
    //根据参数对CALayer进行偏移和旋转Transform
    CATransform3D transform = CATransform3DMakeTranslation([[params objectAtIndex:0] floatValue], [[params objectAtIndex:1] floatValue], [[params objectAtIndex:2] floatValue]);
    transform = CATransform3DRotate(transform, [[params objectAtIndex:3] floatValue], [[params objectAtIndex:4] floatValue], [[params objectAtIndex:5] floatValue], [[params objectAtIndex:6] floatValue]);
    //设置transform属性并把Layer加入到主Layer中
    gradient.transform = transform;
    [_rootLayer addSublayer:gradient];
}

- (int)getCurrentLayer
{
    return currentLayer;
}

- (void)setCurrentLayer:(int)current
{
    currentLayer = current;
}

- (void)layoutSubviews
{
    _rootLayer = [CALayer layer];
    _rootLayer.frame = self.bounds;
    //前
    [self addLayer:@[@0, @0, @20, @0, @0, @0, @0] index:0];
    //后
    [self addLayer:@[@0, @0, @(-20), @(M_PI), @1, @0, @0] index:2];
    //左
    //[self addLayer:@[@(-50), @0, @0, @(-M_PI_2), @0, @1, @0]];
    //右
    //[self addLayer:@[@50, @0, @0, @(M_PI_2), @0, @1, @0]];
    //上
    [self addLayer:@[@0, @(-20), @0, @(M_PI_2), @1, @0, @0] index:3];
    //下
    [self addLayer:@[@0, @20, @0, @(-M_PI_2), @1, @0, @0] index:1];
    
    [self.layer addSublayer:_rootLayer];
    [JDOAdvCell cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(addAnimationWith:) withObject:nil afterDelay:3.0];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"finished:%hhd", flag);
    if (flag == YES) {
        //主Layer的3D变换
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500;
        CABasicAnimation *anim1 = (CABasicAnimation *)anim;
        float value = [anim1.toValue floatValue];
        if (value < 0.25*M_PI) {
            currentLayer = 0;
        } else if (value < 0.75*M_PI) {
            currentLayer = 1;
        } else if (value < 1.25*M_PI) {
            currentLayer = 2;
        } else if (value < 1.75*M_PI) {
            currentLayer = 3;
        }
        transform = CATransform3DRotate(transform, [anim1.toValue floatValue], 1, 0, 0);
        //设置CALayer的sublayerTransform
        _rootLayer.sublayerTransform = transform;
        [_rootLayer removeAllAnimations];
        [self performSelector:@selector(addAnimationWith:) withObject:anim1 afterDelay:3.0];
    } else {
        [JDOAdvCell cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(addAnimationWith:) withObject:nil afterDelay:3.0];
    }
}

- (void)addAnimationWith:(CABasicAnimation *)anim1
{
    if (anim1) {
        [_rootLayer addAnimation:[self animitionRotation:[anim1.toValue floatValue]] forKey:@"rotation"];
    } else {
        [_rootLayer addAnimation:[self animitionRotation:0.0] forKey:@"rotation"];
    }
}

- (CAAnimation *)animitionRotation:(float)start
{
    if (start >= 2*M_PI) {
        start = start - 2*M_PI;
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.x"];
    animation.fromValue = [NSNumber numberWithFloat:start];
    animation.toValue = [NSNumber numberWithFloat:start + 0.5 * M_PI];
    //animation.beginTime = 3.0;
    animation.duration = 1.0;
    animation.autoreverses = NO;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    animation.cumulative = YES;
    animation.repeatCount = 0;
    return animation;
}

@end

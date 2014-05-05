//
//  JDOAdvCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 14-5-5.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOAdvCell.h"

@implementation JDOAdvCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _rootLayer = [CALayer layer];
        //_rootLayer.contentsScale = [UIScreen mainScreen].scale;
        _rootLayer.frame = self.bounds;
        //前
        [self addLayer:@[@0, @0, @40, @0, @0, @0, @0]];
        //后
        [self addLayer:@[@0, @0, @(-40), @(M_PI), @0, @0, @0]];
        //左
        //[self addLayer:@[@(-50), @0, @0, @(-M_PI_2), @0, @1, @0]];
        //右
        //[self addLayer:@[@50, @0, @0, @(M_PI_2), @0, @1, @0]];
        //上
        [self addLayer:@[@0, @(-40), @0, @(-M_PI_2), @1, @0, @0]];
        //下
        [self addLayer:@[@0, @40, @0, @(M_PI_2), @1, @0, @0]];
        
        //主Layer的3D变换
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500;
        //在X轴上做一个20度的小旋转
        //transform = CATransform3DRotate(transform, M_PI / 9, 1, 0, 0);
        //设置CALayer的sublayerTransform
        _rootLayer.sublayerTransform = transform;
        //添加Layer
        [self.layer addSublayer:_rootLayer];
    }
    return self;
}

- (void)addLayer:(NSArray*)params
{
    //创建支持渐变背景的CAGradientLayer
    CALayer *gradient = [CALayer layer];
    //设置位置，和颜色等参数
    //gradient.contentsScale = [UIScreen mainScreen].scale;
    gradient.bounds = CGRectMake(0, 0, 320, 80);
    gradient.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //gradient.colors = @[(id)[UIColor grayColor].CGColor, (id)[UIColor blackColor].CGColor];
    //gradient.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor redColor].CGColor];
    [gradient setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"logo2_with_bg"]].CGColor];
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

- (void)layoutSubviews
{
    //动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.x"];
    //从0到360度
    animation.toValue = [NSNumber numberWithFloat:0.5 * M_PI];
    //间隔3秒
    animation.duration = 2.0;
    //无限循环
    animation.repeatCount = HUGE_VAL;
    //开始动画
    [_rootLayer addAnimation:animation forKey:@"rotation"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

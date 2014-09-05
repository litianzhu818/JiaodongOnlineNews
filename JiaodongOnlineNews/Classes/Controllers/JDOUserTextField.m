//
//  JDOUserTextField.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 14-9-4.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "JDOUserTextField.h"

@implementation JDOUserTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _leftViewPadding = 10;
        _rightViewPadding = 10;
        _leftTextPadding = 10;
        _rightTextPadding = 10;
    }
    return self;
}

//- (CGRect)borderRectForBounds:(CGRect)bounds;
//- (CGRect)clearButtonRectForBounds:(CGRect)bounds;
- (CGRect)textRectForBounds:(CGRect)bounds{
    float leftWidth = 0;
    float rightWidth = 0;
    if (self.leftView) {
        leftWidth = _leftViewPadding+CGRectGetWidth(self.leftView.bounds)+_leftTextPadding;
    }
    if (self.rightView) {
        rightWidth = _rightViewPadding+CGRectGetWidth(self.rightView.bounds)+_rightTextPadding;
    }
    if (leftWidth!=0 || rightWidth!=0) {
        return CGRectMake(leftWidth, CGRectGetMinY(bounds), CGRectGetWidth(bounds)-leftWidth-rightWidth, CGRectGetHeight(bounds));
    }
    return bounds;
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    return [self textRectForBounds:bounds];
}
- (CGRect)editingRectForBounds:(CGRect)bounds{
    return [self textRectForBounds:bounds];
}
- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    if (self.leftView) {
        return  CGRectMake(_leftViewPadding, (CGRectGetHeight(bounds)-CGRectGetHeight(self.leftView.bounds))/2, CGRectGetWidth(self.leftView.bounds), CGRectGetHeight(self.leftView.bounds));
    }
    return CGRectZero;
}
- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    if (self.rightView) {
        return  CGRectMake(CGRectGetWidth(bounds)-_rightViewPadding-CGRectGetWidth(self.rightView.bounds), (CGRectGetHeight(bounds)-CGRectGetHeight(self.rightView.bounds))/2, CGRectGetWidth(self.rightView.bounds), CGRectGetHeight(self.rightView.bounds));
    }
    return CGRectZero;
}

- (void)drawPlaceholderInRect:(CGRect)rect{
    if (_placeHolderColor) {
        if (Is_iOS7) {
            [self.placeholder drawInRect:CGRectInset(rect, 0, 10) withAttributes:@{NSForegroundColorAttributeName:_placeHolderColor,NSFontAttributeName:self.font}];
        }else{
#warning iOS7以下未测试
            [_placeHolderColor set];
            [self.placeholder drawInRect:rect withFont:self.font];
        }
    }else{
        [super drawPlaceholderInRect:rect];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}

//-(void)drawRect:(CGRect)rect{
//    UIBezierPath *path=[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4];
//    [[UIColor grayColor] setStroke];
//    [path setLineWidth:1];
//    [path stroke];
//}

@end

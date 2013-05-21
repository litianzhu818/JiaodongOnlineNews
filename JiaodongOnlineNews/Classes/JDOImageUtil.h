//
//  JDOImageUtil.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-21.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ImageAdjustTypeShrink = 0,  // 缩小到限定区域内，若原始图片比例不符合设备宽高比，会显示出背景
    ImageAdjustTypeStretch  // 拉伸到填充满限定区域，若原始图片比例不符合设备宽高比，图片的一部分会在可视区域外
} ImageAdjustType;

@interface JDOImageUtil : NSObject

+ (UIImage *) adjustImage:(UIImage *)originImg toSize:(CGSize)targetSize type:(ImageAdjustType) type;
+ (UIImage *)resizeImage:(UIImage*)inImage  inRect:(CGRect)thumbRect;

@end

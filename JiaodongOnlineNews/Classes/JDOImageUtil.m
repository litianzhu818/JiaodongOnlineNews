//
//  JDOImageUtil.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-5-21.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOImageUtil.h"

@implementation JDOImageUtil

// 调整图片到目标尺寸,等比缩放
+ (UIImage *)adjustImage:(UIImage *)originImg toSize:(CGSize)targetSize type:(ImageAdjustType) type{
    
    UIImage *adjustedImg;
    float originWidth = originImg.size.width;
    float originHeight = originImg.size.height;
    float targetWidth = targetSize.width;
    float targetHeight = targetSize.height;
    
    #warning 关于拉伸和压缩以及重定义原点的方法有待验证
    if (originWidth != targetWidth || originHeight != targetHeight){
        CGSize size;    // 绘图尺寸
        CGPoint origin; // 绘图原点
        float originRate = originWidth / originHeight;
        float targetRate = targetWidth / targetHeight;
        
        if (type == ImageAdjustTypeStretch) {
            if(originRate > targetRate){
                size = CGSizeMake(targetHeight * originWidth / originHeight, targetHeight);
                origin = CGPointMake((targetWidth- targetHeight*originWidth / originHeight)/2 ,0.0);
            }else{
                size = CGSizeMake(targetWidth, targetWidth * originHeight / originWidth);
                origin = CGPointMake(0.0 , (targetHeight- targetWidth*originHeight / originWidth)/2);
            }
        }else{
            if(originRate > targetRate){
                size = CGSizeMake(targetWidth, targetWidth*originHeight/originWidth);
                origin = CGPointMake(0.0, (targetHeight - targetWidth*originHeight/originWidth)/2 );
            }else{
                size = CGSizeMake(targetHeight*originWidth/originHeight,targetHeight);
                origin = CGPointMake((targetWidth - targetHeight*originWidth/originHeight)/2 , 0.0 );
            }
        }
        UIGraphicsBeginImageContext(targetSize);
        CGRect imageRect = CGRectMake(origin.x, origin.y, size.width, size.height);
        [originImg drawInRect:imageRect];
        adjustedImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        adjustedImg = originImg;
    }
    return adjustedImg;
}

// 非等比缩放，填充满目标区域
+ (UIImage *)resizeImage:(UIImage*)inImage  inRect:(CGRect)thumbRect {
    CGImageRef          imageRef = [inImage CGImage];
    CGImageAlphaInfo    alphaInfo = CGImageGetAlphaInfo(imageRef);
    /* There's a wierdness with kCGImageAlphaNone  and CGBitmapContextCreate
     see Supported Pixel Formats in the Quartz 2D Programming Guide
     Creating a Bitmap Graphics Context section
     only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst,         kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
     The images on input here are likely to be png or jpeg files*/
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    // Build a bitmap context that's the size of the thumbRect
    CGFloat bytesPerRow;
    if( thumbRect.size.width > thumbRect.size.height ) {
        bytesPerRow = 4 * thumbRect.size.width;
    } else {
        bytesPerRow = 4 * thumbRect.size.height;
    }
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                8, //CGImageGetBitsPerComponent(imageRef),  // really needs to always be 8
                                                bytesPerRow, //4 * thumbRect.size.width,    // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                alphaInfo
                                                );
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    return result;
}

@end

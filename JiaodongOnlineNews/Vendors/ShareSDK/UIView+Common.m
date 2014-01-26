//
//  UIView+Common.m
//  JiaodongOnlineNews
//
//  Created by 刘斌 on 14-1-24.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import "UIView+Common.h"

@implementation UIView (Common)
/**
 *	@brief	获取左上角横坐标
 *
 *	@return	坐标值
 */
- (CGFloat)left{
    return self.frame.origin.x;
}


/**
 *	@brief	获取左上角纵坐标
 *
 *	@return	坐标值
 */
- (CGFloat)top{
    return self.frame.origin.y;
}

/**
 *	@brief	获取视图右下角横坐标
 *
 *	@return	坐标值
 */
- (CGFloat)right{
    return self.frame.origin.x + self.frame.size.width;
}

/**
 *	@brief	获取视图右下角纵坐标
 *
 *	@return	坐标值
 */
- (CGFloat)bottom{
    return self.frame.origin.y + self.frame.size.height;
}


/**
 *	@brief	获取视图宽度
 *
 *	@return	宽度值（像素）
 */
- (CGFloat)width{
    return self.frame.size.width;
}


/**
 *	@brief	获取视图高度
 *
 *	@return	高度值（像素）
 */
- (CGFloat)height{
    return self.frame.size.height;
}
@end

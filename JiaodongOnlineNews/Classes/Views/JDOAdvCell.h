//
//  JDOAdvCell.h
//  JiaodongOnlineNews
//
//  Created by Roc on 14-5-5.
//  Copyright (c) 2014年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDOAdvCell : UITableViewCell
{
    CALayer *_rootLayer;
    int currentLayer;
}
@property (nonatomic, strong)NSArray *datas;

- (void)setCurrentLayer:(int)current;
- (int)getCurrentLayer;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier datas:(NSArray *)datas;
@end

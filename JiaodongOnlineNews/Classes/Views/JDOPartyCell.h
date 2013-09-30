//
//  JDOImageCell.h
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-24.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDOCollectView.h"

@class JDOPartyModel;

@interface JDOPartyCell : UITableViewCell

@property (nonatomic,strong) JDOPartyModel *partyModel;

- (void)setModel:(JDOPartyModel *)partyModel;

@end

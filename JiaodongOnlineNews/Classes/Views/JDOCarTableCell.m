//
//  JDOCarTableCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCarTableCell.h"

@implementation JDOCarTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        carNum = [[UILabel alloc] initWithFrame:CGRectMake(10, (44-22)/2, 150, 22)];
        [carNum setBackgroundColor:[UIColor clearColor]];
        [carNum setLineBreakMode:UILineBreakModeWordWrap];
        [carNum setFont:[UIFont systemFontOfSize:18.0]];
        [carNum setTextColor:[UIColor colorWithHex:Gray_Color_Type1]];
        
        checkBox = [[M13Checkbox alloc] initWithTitle:@"自动提醒" andHeight:22.0];
        [checkBox setTitleColor:Gray_Color_Type1];
        checkBox.frame = CGRectMake(self.frame.size.width - 10 - checkBox.frame.size.width, (44-22)/2, checkBox.frame.size.width, checkBox.frame.size.height);
        [checkBox addTarget:self action:@selector(changePushState) forControlEvents:UIControlEventValueChanged];
        
        [self.contentView addSubview:carNum];
        [self.contentView addSubview:checkBox];
        [self setSeparator];
    }
    return self;
}

- (void) changePushState{
    
    NSString *ispush = checkBox.checkState == M13CheckboxStateChecked ? @"1":@"0";
    NSDictionary *param = @{@"hphm":[data objectForKey:@"hphm"],@"ispush":ispush};
    [[JDOJsonClient sharedClient] getPath:SETVIOPUSHPERMISSION_SERVICE parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id status = [(NSDictionary *)responseObject objectForKey:@"status"];
        if ([status isKindOfClass:[NSNumber class]]) {
            int _status = [status intValue];
            if (_status == 1) { //成功
                
            }else if(_status == 0){
                [self dealWithBindError];
            }
        } else if([status isKindOfClass:[NSString class]]){
            if ([status isEqualToString:@"wrongparam"]) {
                NSLog(@"参数错误");
                [self dealWithBindError];
            }else if([status isEqualToString:@"notexist"]){
                NSLog(@"尚未绑定");
#warning 尚未绑定是什么意思
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dealWithBindError];
    }];
    
}

- (void) dealWithBindError{
    NSString *error;
    if(checkBox.checkState == M13CheckboxStateChecked){
        error = @"设置违章推送失败，请稍后再试。";
        [checkBox setCheckState:M13CheckboxStateUnchecked];
    }else{
        error = @"关闭违章推送失败，请稍后再试。";
        [checkBox setCheckState:M13CheckboxStateChecked];
    }
#warning 提示应该显示在tableview级别
//    [JDOCommonUtil showHintHUD:error inView:self.view withSlidingMode:WBNoticeViewSlidingModeUp];
}

- (void)setData:(NSDictionary *)_data
{
    data = _data;
    // 车牌号(车架号)
    [carNum setText:[NSString stringWithFormat:@"%@ (%@)",[data objectForKey:@"hphm"],[data objectForKey:@"vin"]]];
    
}

- (void)enterEditingMode:(BOOL)iseditting
{
    [checkBox setHidden:iseditting];
}

- (void)setSeparator
{
    UIImageView *imageseparator = [[UIImageView alloc] initWithFrame:CGRectMake(-40, self.frame.size.height - 1, 360, 1)];
    [imageseparator setImage:[UIImage imageNamed:@"vio_line2"]];
    [self.contentView addSubview:imageseparator];
}


@end

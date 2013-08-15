//
//  JDOCarTableCell.m
//  JiaodongOnlineNews
//
//  Created by Roc on 13-7-23.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOCarTableCell.h"

@implementation JDOCarTableCell{
    __strong UIView *checkBoxTouch;
    UITapGestureRecognizer *tapCheckBox;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        carNum = [[UILabel alloc] initWithFrame:CGRectMake(10, (44-22)/2, 150, 22)];
        [carNum setBackgroundColor:[UIColor clearColor]];
        [carNum setLineBreakMode:UILineBreakModeWordWrap];
        [carNum setFont:[UIFont systemFontOfSize:18.0]];
        [carNum setTextColor:[UIColor colorWithHex:Gray_Color_Type1]];
        [self.contentView addSubview:carNum];
        
        checkBox = [[M13Checkbox alloc] initWithTitle:@"自动提醒" andHeight:22.0];
        [checkBox setTitleColor:Gray_Color_Type1];
        checkBox.frame = CGRectMake(0, (44-22)/2, checkBox.frame.size.width, checkBox.frame.size.height);
        [checkBox addTarget:self action:@selector(changePushState) forControlEvents:UIControlEventValueChanged];
        
        checkBoxTouch = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 10 - checkBox.frame.size.width, 0, checkBox.frame.size.width+10, 44)];
        tapCheckBox = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transferTapToCheckbox:)];
        [checkBoxTouch addGestureRecognizer:tapCheckBox];
        [checkBoxTouch addSubview:checkBox];
        
        self.accessoryView = checkBoxTouch;
        [self setSeparator];
    }
    return self;
}

- (void)dealloc{
    [checkBoxTouch removeGestureRecognizer:tapCheckBox];
}

- (void) transferTapToCheckbox:(UITapGestureRecognizer *)tap{
    [checkBox toggleCheckState];
    [checkBox sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) changePushState{
#warning 防止快速重复提交,其他弹出提示和可能反复快速提交的地方也应该加此设置
    if ([JDOCommonUtil isShowingHint]) {
        [checkBox toggleCheckState];
        return;
    }
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"JDO_Push_UserId"];
    if (userId == nil) {
        [self dealWithBindError];
    }else{
        BOOL isPush = checkBox.checkState == M13CheckboxStateChecked;
        NSDictionary *param = @{@"userid":userId, @"hphm":[data objectForKey:@"hphm"], @"ispush":isPush ? @"1":@"0"};
        [[JDOJsonClient sharedClient] getPath:SETVIOPUSHPERMISSION_SERVICE parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            id status = [(NSDictionary *)responseObject objectForKey:@"status"];
            if ([status isKindOfClass:[NSNumber class]]) {
                int _status = [status intValue];
                if (_status == 1) { //成功
                    NSMutableArray *carMessageArray = [[NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetDocumentFilePath(@"CarMessage")] mutableCopy];
                    if(carMessageArray != nil){
                        for (int i = 0; i < carMessageArray.count; i++) {
                            NSMutableDictionary *carData = [[carMessageArray objectAtIndex:i] mutableCopy];
                            if ([[carData objectForKey:@"hphm"] isEqualToString:[data objectForKey:@"hphm"]]) {
                                [carData setObject:[NSNumber numberWithBool:isPush] forKey:@"ispush"];
                                [carMessageArray replaceObjectAtIndex:i withObject:carData];
                                [NSKeyedArchiver archiveRootObject:carMessageArray toFile:JDOGetDocumentFilePath(@"CarMessage")];
                            }
                        }
                    }
                }else if(_status == 0){
                    [self dealWithBindError];
                }
            } else if([status isKindOfClass:[NSString class]]){
                if ([status isEqualToString:@"wrongparam"]) {
                    NSLog(@"参数错误");
                    [self dealWithBindError];
                }else if([status isEqualToString:@"notexist"]){
                    NSLog(@"尚未绑定");
                    //正常讲不会出现这种情况,暂时忽略,更完善的方案是在这里重新调用JDOViolationViewController的sendToServer方法进行绑定
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self dealWithBindError];
        }];
    }
}

- (void) dealWithBindError{
    NSString *error;
    if(checkBox.checkState == M13CheckboxStateChecked){
        error = @"未能开启自动提醒，请稍后再试。";
        [checkBox setCheckState:M13CheckboxStateUnchecked];
    }else{
        error = @"未能关闭自动提醒，请稍后再试。";
        [checkBox setCheckState:M13CheckboxStateChecked];
    }
    [JDOCommonUtil showHintHUD:error inView:self.parentTableView withSlidingMode:WBNoticeViewSlidingModeUp];
}

- (void)setData:(NSDictionary *)_data
{
    data = _data;
    // 车牌号(车架号)
    [carNum setText:[NSString stringWithFormat:@"%@ (%@)",[data objectForKey:@"hphm"],[data objectForKey:@"vin"]]];
    [checkBox setCheckState:[[data objectForKey:@"ispush"] boolValue]?M13CheckboxStateChecked:M13CheckboxStateUnchecked];
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

//
//  JDOLivehoodAskQuestion.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-7-5.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDOLivehoodAskQuestion.h"
#import "InsetsTextField.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "ActionSheetCustomPicker.h"
#import "ActionSheetStringPicker.h"
#import "SSTextView.h"

#define Line_Height 35.0f
#define Label_Width 90.0f
#define Input_Width 200.0f
#define Line_Padding 10.0f

#define Hint_Font_Size 13.0f
#define Label_Font_Size 15.0f
#define Content_Font_Size 15.0f

@interface JDOLivehoodAskQuestion () <ActionSheetCustomPickerDelegate,UITextFieldDelegate>

@property (strong,nonatomic) TPKeyboardAvoidingScrollView *mainView;
@property (nonatomic,strong) SSTextView *titleInput;
@property (nonatomic,strong) SSTextView *contentInput;
@property (nonatomic,strong) UIButton *qTypeButton;
@property (nonatomic,strong) UITextField *qPwdInput;
@property (nonatomic,strong) UIButton *qDeptButton;
@property (nonatomic,strong) UIButton *qAreaButton;
@property (nonatomic,strong) UITextField *qNameInput;
@property (nonatomic,strong) UITextField *qTelInput;
@property (nonatomic,strong) UITextField *qEmailInput;

@property (nonatomic,strong) UIButton *qPublicCB;
@property (nonatomic,strong) UIButton *qNotPublicCB;
@property (nonatomic,strong) UIButton *qTelPublicCB;
@property (nonatomic,strong) UIButton *qTelNotPublicCB;

@property (nonatomic,strong) ActionSheetCustomPicker *deptPicker;
@property (nonatomic,strong) ActionSheetStringPicker *typePicker;
@property (nonatomic,strong) ActionSheetStringPicker *areaPicker;


@property (strong, nonatomic) UITapGestureRecognizer *closeInputGesture;
@property (nonatomic,strong) UIView *maskView;

@property (nonatomic, strong) NSDictionary *selectedDept;
@property (nonatomic, strong) NSArray *deptKeys;
@property (nonatomic, strong) NSArray *deptList;



@end

@implementation JDOLivehoodAskQuestion{
    NSArray *typeStrings, *publicStrings, *areaStrings, *telPublicStrings;
    NSArray *typeValues, *publicValues, *areaValues, *telPublicValues;
    NSString *qTypeValue, *qPublicValue, *qAreaValue, *qTelPublicValue;
    BOOL isKeyboardShowing;
    MBProgressHUD *HUD;
}

#warning 输入框背景色若要调整需要替换图片,弹出框样式需要调整
- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info rootView:(UIView *)rootView{
    if ((self = [super init])) {
        typeStrings = @[@"投诉",@"咨询",@"建议",@"反馈"];
        typeValues = @[@"1",@"2",@"3",@"4"];
        
        publicStrings = @[@"公开",@"保密"];
        publicValues = @[@"0",@"1"];
        
        areaStrings = @[@"烟台市",@"芝罘区",@"莱山区",@"福山区",@"牟平区",@"蓬莱市",@"龙口市",@"莱州市",@"招远市",@"栖霞市",@"莱阳市",@"海阳市",@"长岛县",@"开发区"];
        areaValues = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13"];
        
        telPublicStrings = @[@"公开",@"保密"];
        telPublicValues = @[@"1",@"0"];
        
        _deptKeys = @[@"A,C,D,F", @"G", @"H,J,K", @"L,M,N", @"Q,R,S,T", @"W,X", @"Y,Z", @"金融"];

        self.frame = frame;
        self.info = info;
        self.reuseIdentifier = [info valueForKey:@"reuseId"];
        self.rootView = rootView;
        
        self.backgroundColor = [UIColor colorWithHex:Main_Background_Color];// 与html的body背景色相同
        _mainView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.bounds];
        _mainView.backgroundColor = [UIColor colorWithHex:Main_Background_Color];
        [self addSubview:_mainView];
        
        // 提示行
        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 310, 18)];
        hintLabel.backgroundColor = [UIColor clearColor];
        hintLabel.font = [UIFont systemFontOfSize:Hint_Font_Size];
        hintLabel.textColor = [UIColor colorWithHex:@"d73c14"];
        hintLabel.text = @"欢迎使用网上民声留言系统,热点部门将真诚为您服务";
        [self.mainView addSubview:hintLabel];
        
        // 问题标题
        float nextLineY = CGRectGetMaxY(hintLabel.frame)+Line_Padding;
        [self addLabel:@"问题标题" originY:nextLineY+0.15*Line_Height];
//        UILabel *titleHint = [self addLabel:@"字数在5-25之间" originY:nextLineY+18];
//        titleHint.textColor = [UIColor colorWithHex:@"d73c14"];
//        titleHint.font = [UIFont systemFontOfSize:12];
        _titleInput = [self addTextViewOriginY:nextLineY height:Line_Height*1.3];
        _titleInput.placeholder = @"字数在5-25之间";
        
        // 问题内容
        nextLineY += 1.3*Line_Height+Line_Padding;
        UILabel *contentLabel = [self addLabel:@"问题内容" originY:nextLineY];
        contentLabel.frame = CGRectMake(10, nextLineY+1.4*Line_Height, Label_Width, Line_Height);
        _contentInput = [self addTextViewOriginY:nextLineY height:Line_Height*4];
        
        // 问题类型
        nextLineY += Line_Height*4+Line_Padding;
        [self addLabel:@"问题类型" originY:nextLineY];
        _qTypeButton = [self addPopoverBtn:nextLineY];
        [_qTypeButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        
        // 问题是否公开
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"问题是否公开" originY:nextLineY];
        _qPublicCB = [self addCheckboxTitle:@"公开" frame:CGRectMake(Label_Width+20, nextLineY, 100, Line_Height)];
        _qNotPublicCB = [self addCheckboxTitle:@"保密" frame:CGRectMake(Label_Width+20+110, nextLineY, 120, Line_Height)];

        // 查询密码
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"查询密码" originY:nextLineY];
        _qPwdInput = [self addInputField:nextLineY];
        _qPwdInput.placeholder = @"6位数字";
        _qPwdInput.secureTextEntry = true;
        _qPwdInput.keyboardType = UIKeyboardTypeNumberPad;
        
        // 选择部门
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"选择部门" originY:nextLineY];
        _qDeptButton = [self addPopoverBtn:nextLineY];
        
        // 选择所在区域
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"选择所在区域" originY:nextLineY];
        _qAreaButton = [self addPopoverBtn:nextLineY];
        
        // 姓名
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"姓名" originY:nextLineY];
        _qNameInput = [self addInputField:nextLineY];
        
        // 联系电话
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"联系电话" originY:nextLineY];
        _qTelInput = [self addInputField:nextLineY];
        _qTelInput.keyboardType = UIKeyboardTypePhonePad;
        
        // 电话是否公开
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"电话是否公开" originY:nextLineY];
        _qTelPublicCB = [self addCheckboxTitle:@"公开" frame:CGRectMake(Label_Width+20, nextLineY, 100, Line_Height)];
        _qTelNotPublicCB = [self addCheckboxTitle:@"保密" frame:CGRectMake(Label_Width+20+110, nextLineY, 120, Line_Height)];
        
        // 电子邮件
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"电子邮件" originY:nextLineY];
        _qEmailInput = [self addInputField:nextLineY];
        _qEmailInput.keyboardType = UIKeyboardTypeEmailAddress;
        
        nextLineY += Line_Height+Line_Padding;
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:[UIImage imageNamed:@"livehood_continue_button"] forState:UIControlStateNormal];
        [submitBtn setTitle:@"提交问题" forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(submitQuestion) forControlEvents:UIControlEventTouchUpInside];
        submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        submitBtn.frame = CGRectMake(10, nextLineY, 300, 43);
        [self.mainView addSubview:submitBtn];
        
        [_mainView setContentSize:CGSizeMake(320, nextLineY+43+15)];
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (void) submitQuestion{
    // 校验数据合法性
    // 提交数据
    // 清空数据
    // 返回列表
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (UILabel *) addLabel:(NSString *)text originY:(CGFloat) originY{
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, originY, Label_Width, Line_Height)];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
    aLabel.font = [UIFont systemFontOfSize:Label_Font_Size];
    aLabel.text = text;
    [self.mainView addSubview:aLabel];
    return aLabel;
}

- (InsetsTextField *) addInputField:(CGFloat) originY{
    InsetsTextField *aInput = [[InsetsTextField alloc] initWithFrame:CGRectMake(Label_Width+20, originY , Input_Width, Line_Height)];
    aInput.font = [UIFont systemFontOfSize:Content_Font_Size];
    aInput.background = [[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    aInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.mainView addSubview:aInput];
    return aInput;
}

- (SSTextView *) addTextViewOriginY:(CGFloat) originY height:(CGFloat) height {
    SSTextView *aTextView = [[SSTextView alloc] initWithFrame:CGRectMake(Label_Width+20, originY, Input_Width, height)];
    aTextView.backgroundColor = [UIColor clearColor];
    aTextView.font = [UIFont systemFontOfSize:Content_Font_Size];
    aTextView.contentInset = UIEdgeInsetsMake(-4, -2, 0, -2);
    UIImageView *textViewMask = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"inputFieldBorder"] stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    textViewMask.frame = aTextView.frame;
    [self.mainView addSubview:textViewMask];
    [self.mainView addSubview:aTextView];
    return aTextView;
}

- (UIButton *) addPopoverBtn:(CGFloat) originY{
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.frame = CGRectMake(Label_Width+20, originY , Input_Width, Line_Height);
    aButton.titleLabel.font = [UIFont systemFontOfSize:Content_Font_Size];
//    aButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    aButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);//留出下拉箭头的位置
    aButton.adjustsImageWhenHighlighted = false;
    aButton.showsTouchWhenHighlighted = true;
    [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [aButton setBackgroundImage:[UIImage imageNamed:@"inputFieldPopBtnBackground"] forState:UIControlStateNormal];
    [aButton setBackgroundImage:[UIImage imageNamed:@"inputFieldPopBtnBackground"] forState:UIControlStateHighlighted];
    [aButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:aButton];
    return aButton;
}

- (UIButton *) addCheckboxTitle:(NSString *)title frame:(CGRect) frame{
    UIView *aCheckBox = [[UIView alloc] initWithFrame:frame];
    UIButton *checkBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat checkBoxSize = 18.0f;
    checkBoxBtn.frame = CGRectMake(0, (frame.size.height-checkBoxSize)/2, checkBoxSize, checkBoxSize);
    [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"livehood_checkbox_unselected"] forState:UIControlStateNormal];
    [checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"livehood_checkbox_selected"] forState:UIControlStateSelected];
    [checkBoxBtn addTarget:self action:@selector(checkBoxBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [aCheckBox addSubview:checkBoxBtn];
    
    CGFloat labelX = CGRectGetMaxX(checkBoxBtn.frame)+10;
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, frame.size.width-labelX, frame.size.height)];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
    aLabel.font = [UIFont systemFontOfSize:Label_Font_Size];
    aLabel.text = title;
    [aCheckBox addSubview:aLabel];
    
    [_mainView addSubview:aCheckBox];
    return checkBoxBtn;
}

- (void) checkBoxBtnClicked:(UIButton *) btn{
    if (btn.selected){
        return;
    }
    btn.selected = true;
    UIButton *converseBtn;
    if (btn == _qPublicCB ) {
        qPublicValue = [publicStrings objectAtIndex:0];
        converseBtn = _qNotPublicCB;
    }else if(btn == _qNotPublicCB){
        qPublicValue = [publicStrings objectAtIndex:1];
        converseBtn = _qPublicCB;
    }else if(btn == _qTelPublicCB){
        qTelPublicValue = [telPublicStrings objectAtIndex:0];
        converseBtn = _qTelNotPublicCB;
    }else if(btn == _qTelNotPublicCB){
        qTelPublicValue = [telPublicStrings objectAtIndex:1];
        converseBtn = _qTelPublicCB;
    }
    converseBtn.selected = false;
}

- (void)keyboardWillShow:(NSNotification *)notification{
    if (isKeyboardShowing == false){
        _closeInputGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
        _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320 , App_Height)];
        _maskView.backgroundColor = [UIColor clearColor];
        [self.rootView.superview insertSubview:_maskView aboveSubview:self.rootView];
        [self.maskView addGestureRecognizer:_closeInputGesture];
        [SharedAppDelegate deckController].enabled = false;
        isKeyboardShowing = true;
    }
}

- (void) hideKeyboard:(UIGestureRecognizer *)gesture{
    // 遍历所有可输入控件
    for(UIView *subView in [_mainView subviews]){
        if([subView isKindOfClass:[UIResponder class]]){
            UIResponder *inputControl = (UIResponder *)subView;
            if( [inputControl isFirstResponder]){
                [inputControl resignFirstResponder];
                break;
            }
        }
    }
    [_maskView removeGestureRecognizer:self.closeInputGesture];
    [_maskView removeFromSuperview];
    [SharedAppDelegate deckController].enabled = true;
    isKeyboardShowing = false;
}

- (void)keyboardWillHide:(NSNotification *)notification{

}

#pragma mark 选择部门
- (void) showActionSheet:(UIButton *)sender{
    if (sender == _qTypeButton){
        if (_typePicker == nil){
            _typePicker = [[ActionSheetStringPicker alloc] initWithTitle:@"问题类型" rows:typeStrings initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                [_qTypeButton setTitle:[typeStrings objectAtIndex:selectedIndex] forState:UIControlStateNormal];
                qTypeValue =  [typeValues objectAtIndex:selectedIndex];
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                
            } origin:sender];
        }
        [_typePicker showActionSheetPicker];
    }else if (sender == _qAreaButton){
        if (_areaPicker == nil){
            _areaPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择区域" rows:areaStrings initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                [_qAreaButton setTitle:[areaStrings objectAtIndex:selectedIndex] forState:UIControlStateNormal];
                qAreaValue =  [areaValues objectAtIndex:selectedIndex];
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                
            } origin:sender];
        }
        [_areaPicker showActionSheetPicker];
    }else if( sender == _qDeptButton){
        if (_deptPicker == nil){
            _deptPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"选择部门" delegate:self showCancelButton:true origin:sender];
        }
        [_deptPicker showActionSheetPicker];
    }
}

- (void)configurePickerView:(UIPickerView *)pickerView{
    pickerView.showsSelectionIndicator = true;
    [self pickerView:pickerView didSelectRow:0 inComponent:0];
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
    [_qDeptButton setTitle:[_selectedDept objectForKey:@"dept_name"] forState:UIControlStateNormal];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0: return [_deptKeys count];
        case 1: return [_deptList count];
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (component) {
        case 0: return 100.0f;
        case 1: return 200.0f;
    }
    return 0;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 35.0f;
}

// 返回NSString的版本不能改变样式,使用返回UIView的版本
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    switch (component) {
//        case 0: return [_deptKeys objectAtIndex:row];
//        case 1: return [[_deptList objectAtIndex:row] objectForKey:@"dept_name"];
//    }
//    return nil;
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if( component ==0 ){
        if(view == nil){
            UILabel *deptKeyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100-20, 35)];
            deptKeyLabel.textColor = [UIColor blackColor];
            deptKeyLabel.font = [UIFont systemFontOfSize:15];
            deptKeyLabel.text = [_deptKeys objectAtIndex:row];
            deptKeyLabel.backgroundColor = [UIColor clearColor];
            return deptKeyLabel;
        }else{
            [(UILabel *)view setText:[_deptKeys objectAtIndex:row]];
            return view;
        }
    }else{
        if(view == nil){
            UILabel *deptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200-20, 35)];
            deptLabel.textColor = [UIColor blackColor];
            deptLabel.font = [UIFont systemFontOfSize:15];
            deptLabel.text = [[_deptList objectAtIndex:row] objectForKey:@"dept_name"];
            deptLabel.backgroundColor = [UIColor clearColor];
            return deptLabel;
        }else{
            [(UILabel *)view setText:[[_deptList objectAtIndex:row] objectForKey:@"dept_name"]];
            return view;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0){
        // 从本地缓存读取部门列表
        NSArray *deptList = [NSKeyedUnarchiver unarchiveObjectWithFile: JDOGetCacheFilePath( [@"LivehoodDeptCache" stringByAppendingFormat:@"%d",row+1] )];
        //本地json缓存不存在
        if( deptList == nil){
            // 从网络获取,并写入json缓存文件,记录上次更新时间
            [self loadDataFromNetwork:row];
        }else{
            NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:Dept_Update_Time] mutableCopy];
            NSString *sectionKey = [NSString stringWithFormat:@"DeptSection%d",row+1];
            if( updateTimes && [updateTimes objectForKey:sectionKey]){
                double lastUpdateTime = [(NSNumber *)[updateTimes objectForKey:sectionKey] doubleValue];
                // 上次加载时间离现在超过时间间隔
                if( [[NSDate date] timeIntervalSince1970] - lastUpdateTime > Dept_Update_Interval/**/ ){
                    [self loadDataFromNetwork:row];
                }else{  // 使用缓存deptList
                    _deptList = deptList;
                    [pickerView reloadComponent:1];
                    if (_deptList.count > 0){
                        [pickerView selectRow:0 inComponent:1 animated:true];
                        // 不会调用didSelectRow的回调,手动设置
                        _selectedDept = [_deptList objectAtIndex:0];
                    }
                }
            }else{  // 没有该section的上次刷新时间,正常不会进入该分支,因为既然存在缓存文件就应该记录过刷新时间,除非被删除过
                [self loadDataFromNetwork:row];
            }
        }
    }else{
        _selectedDept = [_deptList objectAtIndex:row];
    }
}

- (void)loadDataFromNetwork:(int) row{
    // 检查网络可用性
    if( ![Reachability isEnableNetwork]){
        [JDOCommonUtil showHintHUD:No_Network_Connection inView:self];
        return;
    }
    NSString *deptKey = [_deptKeys objectAtIndex:row];
    if([deptKey isEqualToString:@"金融"]){
        deptKey = @"B";
    }
    NSDictionary *param = @{@"letter":deptKey};
    // 加载列表
    [[JDOJsonClient sharedClient] getJSONByServiceName:BRANCHS_LIST_SERVICE modelClass:nil params:param success:^(NSArray *dataList) {
        if( dataList != nil && dataList.count > 0){  /* NSDictionary : dept_code,dept_name */
            [self recordLastUpdateSuccessTime:row];
            [NSKeyedArchiver archiveRootObject:dataList toFile:JDOGetCacheFilePath( [@"LivehoodDeptCache" stringByAppendingFormat:@"%d",row+1] )];
            _deptList = dataList;
            [(UIPickerView *)_deptPicker.pickerView reloadComponent:1];
            if (_deptList.count > 0){
                [(UIPickerView *)_deptPicker.pickerView selectRow:0 inComponent:1 animated:true];
                // 不会调用didSelectRow的回调,手动设置
                _selectedDept = [_deptList objectAtIndex:0];
            }
        }
    } failure:^(NSString *errorStr) {

    }];
}

- (void) recordLastUpdateSuccessTime:(int) row{
    NSMutableDictionary *updateTimes = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:Dept_Update_Time] mutableCopy];
    if( updateTimes == nil){
        updateTimes = [[NSMutableDictionary alloc] initWithCapacity:_deptKeys.count];
    }
    [updateTimes setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:[NSString stringWithFormat:@"DeptSection%d",row+1]];
    [[NSUserDefaults standardUserDefaults] setObject:updateTimes forKey:Dept_Update_Time];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    if (textField == _qDeptInput) {
//        return false;
//    }
//    return true;
//}


@end

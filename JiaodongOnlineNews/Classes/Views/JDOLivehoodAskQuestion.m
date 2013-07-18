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
#import "M13Checkbox.h"
#import "ActionSheetCustomPicker.h"

#define Line_Height 27.0f
#define Label_Width 90.0f
#define Input_Width 200.0f
#define Line_Padding 10.0f

#define Hint_Font_Size 13.0f
#define Label_Font_Size 15.0f
#define Content_Font_Size 15.0f

@interface JDOLivehoodAskQuestion () <ActionSheetCustomPickerDelegate,UITextFieldDelegate>

@property (strong,nonatomic) TPKeyboardAvoidingScrollView *mainView;
@property (nonatomic,strong) UITextView *titleInput;
@property (nonatomic,strong) UITextView *contentInput;
@property (nonatomic,strong) UIButton *typeButton;
@property (nonatomic,strong) UITextField *qPwdInput;
@property (nonatomic,strong) UITextField *qDeptInput;
@property (nonatomic,strong) UITextField *qNameInput;

@property (nonatomic,strong) M13Checkbox *publicCB;
@property (nonatomic,strong) M13Checkbox *notPublicCB;
@property (nonatomic,strong) ActionSheetCustomPicker *deptPicker;

@property (strong, nonatomic) UITapGestureRecognizer *closeInputGesture;
@property (nonatomic,strong) UIView *maskView;

@property (nonatomic, strong) NSDictionary *selectedDept;
@property (nonatomic, strong) NSArray *deptKeys;
@property (nonatomic, strong) NSArray *deptList;



@end

@implementation JDOLivehoodAskQuestion{
    NSArray *qType,*qPublic,*qArea,*telPublic;
    int qTypeIndex,qPublicIndex,qAreaIndex,qTelPublicIndex;
    BOOL isKeyboardShowing;
    MBProgressHUD *HUD;
}

#warning 输入框背景色若要调整需要替换图片,弹出框样式需要调整
- (id)initWithFrame:(CGRect)frame info:(NSDictionary *)info rootView:(UIView *)rootView{
    if ((self = [super init])) {
        qType = @[@"投诉",@"咨询",@"建议",@"反馈"];
        qPublic = @[@"公开",@"保密"];
        qArea = @[@"烟台市",@"芝罘区",@"莱山区",@"福山区",@"牟平区",@"蓬莱市",@"龙口市",@"莱州市",@"招远市",@"栖霞市",@"",@"莱阳市",@"海阳市",@"长岛县",@"开发区"];
        telPublic = @[@"保密",@"公开"];
        qTypeIndex = qPublicIndex = qAreaIndex = qTelPublicIndex = -1;
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
        [self addLabel:@"问题标题" originY:nextLineY];
        _titleInput = [self addTextViewOriginY:nextLineY height:Line_Height*1.65];
        nextLineY += 0.65*Line_Height;
        UILabel *titleHint = [self addLabel:@"字数在5-25之间" originY:nextLineY+1.5];
        titleHint.textColor = [UIColor colorWithHex:@"d73c14"];
        titleHint.font = [UIFont systemFontOfSize:12];
        
        // 问题内容
        nextLineY += Line_Height+Line_Padding;
        UILabel *contentLabel = [self addLabel:@"问题内容" originY:nextLineY];
        contentLabel.frame = CGRectMake(10, nextLineY+1.4*Line_Height, Label_Width, Line_Height);
        _contentInput = [self addTextViewOriginY:nextLineY height:Line_Height*4];
        
        // 问题类型
        nextLineY += Line_Height*4+Line_Padding;
        [self addLabel:@"问题类型" originY:nextLineY];
        _typeButton = [self addPopoverBtn:nextLineY];
        [_typeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // 问题是否公开
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"问题是否公开" originY:nextLineY];
        _publicCB = [self addCheckboxTitle:@"公开" frame:CGRectMake(Label_Width+20, nextLineY+2, 100, Line_Height-4)];
        _notPublicCB = [self addCheckboxTitle:@"保密" frame:CGRectMake(Label_Width+20+110, nextLineY+2, 120, Line_Height-4)];

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
        _qDeptInput = [self addInputField:nextLineY];
        _qDeptInput.delegate = self;
        [_qDeptInput addTarget:self action:@selector(showDeptActionSheet:) forControlEvents:UIControlEventTouchDown];
        
        // 选择所在区域
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"选择所在区域" originY:nextLineY];
        _qNameInput = [self addInputField:nextLineY];
        
        // 姓名
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"姓名" originY:nextLineY];
        _qNameInput = [self addInputField:nextLineY];
        
        // 联系电话
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"联系电话" originY:nextLineY];
        _qNameInput = [self addInputField:nextLineY];
        
        // 电话是否公开
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"电话是否公开" originY:nextLineY];
        _qNameInput = [self addInputField:nextLineY];
        
        // 电子邮件
        nextLineY += Line_Height+Line_Padding;
        [self addLabel:@"电子邮件" originY:nextLineY];
        _qNameInput = [self addInputField:nextLineY];
        
        nextLineY += Line_Height+Line_Padding;
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:[UIImage imageNamed:@"livehood_continue_button"] forState:UIControlStateNormal];
        [submitBtn setTitle:@"提交问题" forState:UIControlStateNormal];
        [submitBtn addTarget:self action:@selector(submitReview) forControlEvents:UIControlEventTouchUpInside];
        submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        submitBtn.frame = CGRectMake(10, nextLineY, 300, 43);
        [self.mainView addSubview:submitBtn];
        
        [_mainView setContentSize:CGSizeMake(320, nextLineY+43+15)];
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
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

- (UITextView *) addTextViewOriginY:(CGFloat) originY height:(CGFloat) height {
    UITextView *aTextView = [[UITextView alloc] initWithFrame:CGRectMake(Label_Width+20, originY, Input_Width, height)];
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
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    aButton.frame = CGRectMake(Label_Width+20, originY , Input_Width, Line_Height);
    aButton.titleLabel.font = [UIFont systemFontOfSize:Content_Font_Size];
    [self.mainView addSubview:aButton];
    return aButton;
}

- (M13Checkbox *) addCheckboxTitle:(NSString *)title frame:(CGRect) frame{
    M13Checkbox *aCheckBox = [[M13Checkbox alloc] initWithFrame:frame];
    aCheckBox.strokeColor = [UIColor colorWithHex:@"969696"];
    aCheckBox.titleLabel.font = [UIFont systemFontOfSize:Label_Font_Size];
    aCheckBox.titleLabel.textColor = [UIColor colorWithHex:Light_Blue_Color];
    [aCheckBox setCheckAlignment:M13CheckboxAlignmentLeft];
    [aCheckBox setTitle:title];
    [_mainView addSubview:aCheckBox];
    return aCheckBox;
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

#pragma mark 弹出窗口

- (void) buttonClicked:(UIButton *)btn{
    [PopoverView showPopoverAtPoint:btn.center
                                  inView:_mainView
                               withTitle:@"问题类型"
                         withStringArray:qType
                                delegate:self];
}

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index{
    
    qTypeIndex = index;
//    [popoverView showImage:[UIImage imageNamed:@"success"] withMessage:[qType objectAtIndex:index]];
    
    [popoverView showSuccess];
//    [popoverView showError];
    
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView {
    if(qTypeIndex != -1){
        [_typeButton setTitle:[qType objectAtIndex:qTypeIndex] forState:UIControlStateNormal];
    }
}

#pragma mark 选择部门
- (void) showDeptActionSheet:(UIControl *)sender{
    if (_deptPicker == nil){
        _deptPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"选择部门" delegate:self showCancelButton:true origin:sender];
    }
    [_deptPicker showActionSheetPicker];
}

- (void)configurePickerView:(UIPickerView *)pickerView{
    pickerView.showsSelectionIndicator = true;
    [self pickerView:pickerView didSelectRow:0 inComponent:0];
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin{
    _qDeptInput.text = [_selectedDept objectForKey:@"dept_name"];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _qDeptInput) {
        return false;
    }
    return true;
}


@end

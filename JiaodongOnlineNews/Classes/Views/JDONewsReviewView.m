//
//  JDONewsReviewView.m
//  JiaodongOnlineNews
//
//  Created by zhang yi on 13-6-16.
//  Copyright (c) 2013年 胶东在线. All rights reserved.
//

#import "JDONewsReviewView.h"
#import "UIColor+SSToolkitAdditions.h"
#import <ShareSDK/ShareSDK.h>
#import "AGCustomShareItemView.h"
#import "JDOShareViewDelegate.h"

#define Review_Text_Init_Height 44
#define Review_ShareBar_Height 40
#define Review_Input_Height 35

#define Review_Left_Margin 10
#define Review_Right_Margin 10
#define SubmitBtn_Width 55
#define Review_Content_MaxLength 100
#define Review_SubmitBtn_Tag 200

@interface JDONewsReviewView ()

@property (strong, nonatomic) CMHTableView *tableView;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) NSMutableArray *shareTypeArray;

@end

@implementation JDONewsReviewView{
    JDOShareViewDelegate *shareViewDelegate;
}

- (id)initWithTarget:(id<JDOReviewTargetDelegate>)target
{
    self = [super initWithFrame: [self initialFrame]];
    if (self) {
        self.target = target;
        self.backgroundColor = [UIColor colorWithHex:@"f0f0f0"];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        // HPGrowingTextView根据字体的大小有最小高度限制,15号字最少需要35的高度
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(Review_Left_Margin, (Review_Text_Init_Height-Review_Input_Height)/2.0, 240+5, Review_Input_Height)];
        _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 4;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.delegate = self;
        _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
//        _textView.animateHeightChange = NO; //turns off animation
        _textView.backgroundColor = [UIColor whiteColor];
        

#warning 未测试非retina屏幕是否必须不带2x的图片
        // 必须有2x的图片!!!!!否则retina下不起作用,即使图片大小满足2x的尺寸也不行
        UIImage *inputMaskImg = [[UIImage imageNamed:@"inputField"] stretchableImageWithLeftCapWidth:0 topCapHeight:10];
//        UIImage *inputBorderImg = [[UIImage imageNamed:@"inputField"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        UIImageView *inputMask = [[UIImageView alloc] initWithImage:inputMaskImg];
        
        inputMask.frame = CGRectMake(0, 0, 320, Review_Text_Init_Height);
        inputMask.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
//        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inputFieldType2"]];
//        background.frame = CGRectMake(0, 0, 320, Review_Text_Init_Height);
//        background.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
        
//        [self addSubview:background];
        [self addSubview:_textView];
        [self addSubview:inputMask];
        
        UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom] ;
        submitBtn.tag = Review_SubmitBtn_Tag;
        submitBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        submitBtn.frame = CGRectMake(320-Review_Right_Margin-SubmitBtn_Width, (Review_Text_Init_Height-30)/2.0, SubmitBtn_Width, 30);
        [submitBtn addTarget:target action:@selector(submitReview:) forControlEvents:UIControlEventTouchUpInside];
        [submitBtn setTitle:@"发表" forState:UIControlStateNormal];
        [submitBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        submitBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:[UIImage imageNamed:@"inputSendButton"] forState:UIControlStateNormal];
        [submitBtn setBackgroundImage:[UIImage imageNamed:@"inputSendButton"] forState:UIControlStateSelected];
        [self addSubview:submitBtn];
        
        _remainWordNum = [[UILabel alloc] initWithFrame:CGRectMake(320-Review_Right_Margin-SubmitBtn_Width+2, 7, SubmitBtn_Width, 30)];
        _remainWordNum.hidden = true;
        _remainWordNum.backgroundColor =[UIColor clearColor];
        _remainWordNum.numberOfLines = 2;
        _remainWordNum.font = [UIFont systemFontOfSize:12];
        _remainWordNum.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_remainWordNum];
        
        // 分享栏
//        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _textLabel.backgroundColor = [UIColor clearColor];
//        _textLabel.textColor = [UIColor colorWithHex:@"d2d2d2"];
//        _textLabel.text = @"分享到:";
//        _textLabel.font = [UIFont boldSystemFontOfSize:12];
//        [_textLabel sizeToFit];
//        _textLabel.frame = CGRectMake(3, Review_Text_Init_Height, _textLabel.frame.size.width + 3, Review_ShareBar_Height);
//        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
//        _textLabel.contentMode = UIViewContentModeCenter;
//        [self addSubview:_textLabel];
//        float tableViewX = _textLabel.frame.origin.x+_textLabel.frame.size.width;
   
        _tableView = [[CMHTableView alloc] initWithFrame:CGRectMake(7, Review_Text_Init_Height-7.0/2, 320-14, Review_ShareBar_Height)];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.itemWidth = 38;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_tableView];
        
        _shareTypeArray = [JDOCommonUtil getAuthList];
        
        shareViewDelegate = [[JDOShareViewDelegate alloc] initWithPresentView:nil backBlock:^{
//            [self.target writeReview];
#warning 偶尔会在返回评论界面时，无法关闭输入界面(点blackMask部分没有反应)
            // 立刻执行会造成输入框与键盘脱离，0.5是经过实验得到的比较合适的延时
            [(NSObject *)self.target performSelector:@selector(writeReview) withObject:nil afterDelay:0.5];
        } completeBlock:^{
            [(NSObject *)self.target performSelector:@selector(writeReview) withObject:nil afterDelay:0.5];
        }];
        
        // 在这里设置object参数无效,但在controller的viewDidLoad里可以,原因不明,暂时使用nil
        [[NSNotificationCenter defaultCenter] addObserver:self.target selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];    
        [[NSNotificationCenter defaultCenter] addObserver:self.target selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.target name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.target name:UIKeyboardWillHideNotification object:nil];
}

- (CGRect) initialFrame{
    return CGRectMake(0, App_Height, 320, Review_Text_Init_Height+Review_ShareBar_Height);
}

- (NSArray *)selectedClients
{
    NSMutableArray *clients = [NSMutableArray array];
    
    for (int i = 0; i < [_shareTypeArray count]; i++)
    {
        NSDictionary *item = [_shareTypeArray objectAtIndex:i];
        if ([[item objectForKey:@"selected"] boolValue])
        {
            [clients addObject:[item objectForKey:@"type"]];
        }
    }
    
    return clients;
}

#pragma mark - CMHTableViewDataSource

- (NSInteger)itemNumberOfTableView:(CMHTableView *)tableView
{
    return [_shareTypeArray count];
}

- (UIView<ICMHTableViewItem> *)tableView:(CMHTableView *)tableView itemForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"item";
    AGCustomShareItemView *itemView = (AGCustomShareItemView *)[tableView dequeueReusableItemWithIdentifier:reuseId];
    if (itemView == nil){
        itemView = [[AGCustomShareItemView alloc] initWithReuseIdentifier:reuseId clickHandler:^(NSIndexPath *indexPath) {
            if (indexPath.row < [_shareTypeArray count]){
                
                NSMutableDictionary *item = [_shareTypeArray objectAtIndex:indexPath.row];
                ShareType shareType = [[item objectForKey:@"type"] integerValue];
              
                if ([ShareSDK hasAuthorizedWithType:shareType]){
                    BOOL selected = ! [[item objectForKey:@"selected"] boolValue];
                    [item setObject:[NSNumber numberWithBool:selected] forKey:@"selected"];
                    // 保留选中的分享项目到文件中
                    [_shareTypeArray writeToFile:JDOGetDocumentFilePath(@"authListCache.plist") atomically:YES];
                    [_tableView reloadData];
                }else{
                    [self.target hideReviewView];   // 进入绑定界面,绑定完成后重新显示键盘
                    id<ISSAuthOptions> authOptions = JDOGetOauthOptions(shareViewDelegate);
                  
                    [ShareSDK getUserInfoWithType:shareType authOptions:authOptions result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                        if (result){
                            [item setObject:[userInfo nickname] forKey:@"username"];
                            [item setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                            [_shareTypeArray writeToFile:JDOGetDocumentFilePath(@"authListCache.plist") atomically:YES];
                            [_tableView reloadData];
                        }else{
                            if ([error errorCode] != -103){
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"绑定失败" message:[error errorDescription] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
                }
            }
        }];
    }
    
    if (indexPath.row < [_shareTypeArray count]){
        NSDictionary *item = [_shareTypeArray objectAtIndex:indexPath.row];
        UIImage *icon = [ShareSDK getClientIconWithType:[[item objectForKey:@"type"] integerValue]];
        itemView.iconImageView.image = icon;
        
#warning 可以根据未授权,已授权未选中,已选中区分为三种状态表示
        if ([[item objectForKey:@"selected"] boolValue]){
            itemView.iconImageView.alpha = 1;
        }else{
            itemView.iconImageView.alpha = 0.3;
        }
    }
    
    return itemView;
}

#pragma mark - GrowingTextView delegate

//- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;
//- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView;

//- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView;
//- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
#warning 复制粘贴的情况可能超过规定的字数
    if (range.location>=Review_Content_MaxLength)  return  NO;
    return YES;
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    // 计算剩余可输入字数
    int remain = Review_Content_MaxLength-_textView.text.length;
    [_remainWordNum setText:[NSString stringWithFormat:@"还有%d字可以输入",remain<0 ? 0:remain]];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.frame = r;
    
    if(r.size.height > 140){
        [_remainWordNum setHidden:false];
    }else{
        [_remainWordNum setHidden:true];
    }
}
//- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height;

//- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView;
//- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView;

#pragma mark - TextView delegate

//- (void)textViewDidBeginEditing:(UITextView *)textView{
//
//}
//- (void)textViewDidEndEditing:(UITextView *)textView{
//
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if (range.location>=Review_Max_Length){
//        return  NO;
//    }else{
//        return YES;
//    }
//}
//
//- (void)textViewDidChange:(UITextView *)textView{
//    int remain = Review_Max_Length-textView.text.length;
//    [(UILabel *)[self.reviewPanel viewWithTag:Remain_Word_Label] setText:[NSString stringWithFormat:@"还有%d字可输入",remain<0 ? 0:remain]];
//}
//
//- (void)textViewDidChangeSelection:(UITextView *)textView{
//
//}


@end

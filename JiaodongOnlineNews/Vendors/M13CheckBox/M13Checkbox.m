//
//  M13Checkbox.m
//  M13Checkbox-UIRadioGroup
//
/*Copyright (c) 2012 Brandon McQuilkin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "M13Checkbox.h"

#define kBoxSize 0.9
#define kCheckHorizontalExtention 0.1
#define kCheckVerticalExtension 0.1
#define kCheckBoxSpacing 0.4
#define kM13CheckboxMaxFontSize 30.0


//自定义的方框
@interface CheckImageView : UIImageView

@property (nonatomic, retain) M13Checkbox *checkbox;

@end

@implementation CheckImageView
@synthesize checkbox;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *selectimage = [UIImage imageNamed:@"vio_checkbox_selected"];
        UIImage *unselectimage = [UIImage imageNamed:@"vio_checkbox"];
        UIImage *fillimage = [[UIImage alloc] init];
        if (checkbox.checkState == M13CheckboxStateUnchecked) {
            fillimage = unselectimage;
        } else {
            fillimage = selectimage;
        }
        
        [self setImage:fillimage];
    }
    return self;
}

- (void)updateState
{
    UIImage *selectimage = [UIImage imageNamed:@"vio_checkbox_selected"];
    UIImage *unselectimage = [UIImage imageNamed:@"vio_checkbox"];
    UIImage *fillimage = [[UIImage alloc] init];
    if (checkbox.checkState == M13CheckboxStateUnchecked) {
        fillimage = unselectimage;
    } else {
        fillimage = selectimage;
    }
    [self setImage:fillimage];
}

@end

//User Visible Properties
@interface M13Checkbox ()

@property (nonatomic, assign) CGRect boxFrame;

@end

@implementation M13Checkbox
{
    //CheckView *checkView;
    CheckImageView *checkImage;
    UIColor *labelColor;
}

@synthesize flat = _flat;
@synthesize titleLabel = _titleLabel;
@synthesize checkState = _checkState;
@synthesize boxFrame;
@synthesize checkAlignment = _checkAlignment;
@synthesize enabled = _enabled;
@synthesize checkedValue;
@synthesize uncheckedValue;
@synthesize mixedValue;

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, M13CheckboxDefaultHeight, M13CheckboxDefaultHeight)];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _flat = NO;
        _checkAlignment = M13CheckboxAlignmentRight;
        _checkState = M13CheckboxStateUnchecked;
        _enabled = YES;
        checkImage = [[CheckImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), 0, ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), self.frame.size.height)];
        checkImage.checkbox = self;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * kCheckVerticalExtension, self.frame.size.width - checkImage.frame.size.width - (self.frame.size.height * kCheckBoxSpacing), self.frame.size.height * kBoxSize)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.userInteractionEnabled = NO;
        [self autoFitFontToHeight];
        [self addSubview:checkImage];
        [self addSubview:_titleLabel];
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setTitleColor:(NSString *)titleColor
{
    [_titleLabel setTextColor:[UIColor colorWithHex:titleColor]];
}


- (id)initWithTitle:(NSString *)title
{
    self = [self initWithFrame:CGRectMake(0, 0, 100.0, M13CheckboxDefaultHeight)];
    if (self) {
        _titleLabel.text = title;
        [self autoFitFontToHeight];
        CGSize labelSize = [title sizeWithFont:_titleLabel.font];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width + (self.frame.size.height * kCheckBoxSpacing) + ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), self.frame.size.height);
        [self layoutSubviews];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title andHeight:(CGFloat)height
{
    self = [self initWithFrame:CGRectMake(0, 0, 100.0, height)];
    if (self) {
        _titleLabel.text = title;
        [self autoFitFontToHeight];
        CGSize labelSize = [title sizeWithFont:_titleLabel.font];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width + (self.frame.size.height * kCheckBoxSpacing) + ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), self.frame.size.height);
        [self layoutSubviews];
    }
    return self;
}

- (void)autoFitFontToHeight
{
    CGFloat height = self.frame.size.height * kBoxSize;
    CGFloat fontSize = kM13CheckboxMaxFontSize;
    CGFloat tempHeight = MAXFLOAT;
    
    do {
        fontSize -= 1;
        tempHeight = [UIFont systemFontOfSize:fontSize].lineHeight;
    } while (tempHeight >= height);
    _titleLabel.font = [UIFont systemFontOfSize:fontSize+2];
}

- (void)autoFitWidthToText
{
    CGSize labelSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width + (self.frame.size.height * kCheckBoxSpacing) + ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), self.frame.size.height);
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    if (_checkAlignment == M13CheckboxAlignmentRight) {
        checkImage.frame = CGRectMake(self.frame.size.width - ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), 0, ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), self.frame.size.height);
        _titleLabel.frame = CGRectMake(0, self.frame.size.height * kCheckVerticalExtension, self.frame.size.width - checkImage.frame.size.width - (self.frame.size.height * kCheckBoxSpacing), self.frame.size.height * kBoxSize);
    } else {
        checkImage.frame = CGRectMake(0, 0, ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), self.frame.size.height);
        _titleLabel.frame = CGRectMake(checkImage.frame.size.width + (self.frame.size.height * kCheckBoxSpacing), self.frame.size.height * kCheckVerticalExtension, self.frame.size.width - (self.frame.size.height * (kBoxSize + kCheckHorizontalExtention + kCheckBoxSpacing)), self.frame.size.height * kBoxSize);
    }
}

- (void)setState:(M13CheckboxState)state __attribute((deprecated("use setCheckState method")))
{
    [self setCheckState:state];
}

- (void)setCheckState:(M13CheckboxState)checkState{
    _checkState = checkState;
    [checkImage updateState];
}

- (void)toggleState __attribute((deprecated("use toggleCheckState method")))
{
    [self toggleCheckState];
}

- (void)toggleCheckState
{

    self.checkState = !self.checkState;
}

- (void)setEnabled:(BOOL)enabled
{
    if (enabled) {

    } else {
        labelColor = [UIColor colorWithHex:Gray_Color_Type1];
        float r, g, b, a;
        [labelColor getRed:&r green:&g blue:&b alpha:&a];
        r = floorf(r * 100.0 + 0.5) / 100.0;
        g = floorf(g * 100.0 + 0.5) / 100.0;
        b = floorf(b * 100.0 + 0.5) / 100.0;
    }
    _enabled = enabled;
    [checkImage updateState];
}

- (void)setCheckAlignment:(M13CheckboxAlignment)checkAlignment
{
    _checkAlignment = checkAlignment;
    [self layoutSubviews];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self autoFitFontToHeight];
    CGSize labelSize = [title sizeWithFont:_titleLabel.font];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width + (self.frame.size.height * kCheckBoxSpacing) + ((kBoxSize + kCheckHorizontalExtention) * self.frame.size.height), self.frame.size.height);
    [self layoutSubviews];
}

- (BOOL)isChecked
{
    if (self.checkState == M13CheckboxStateChecked) {
        return YES;
    } else {
        return NO;
    }
}

- (id)value
{
    if (self.checkState == M13CheckboxStateUnchecked) {
        return uncheckedValue;
    } else if (self.checkState == M13CheckboxStateChecked) {
        return checkedValue;
    } else {
        return mixedValue;
    }
}

#pragma mark - UIControl overrides

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self toggleCheckState];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
}

@end


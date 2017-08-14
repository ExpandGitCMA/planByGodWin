//
//  DFCRefCodeField.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCRefCodeField.h"
#import "DFCColorDef_pch.h"
#import "DFCButtonStyle.h"
#import "DFCUtility.h"
#import "DFCHeader_pch.h"
@interface DFCRefCodeField ()
@property (nonatomic,strong) UIImage *imgLine;
@property (nonatomic,weak)   UIView *underLine;
@property (nonatomic,strong) UIImageView *imgIcon;
@end

@implementation DFCRefCodeField
-(instancetype)initWithFrame:(CGRect)frame imgIcon:(NSString*)imgIcon holder:(NSString*)holder{
    
    if (self = [super initWithFrame:frame]) {
        UIImage *icon = [UIImage imageNamed:imgIcon];
        _imgIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, (self.frame.size.height-icon.size.height)/2, icon.size.width, icon.size.height)];
        _imgIcon.image = icon;
        [self addSubview:_imgIcon];
        
        _imgLine = [UIImage imageNamed:@"register_line"];
        UIImageView *imgViewSearch = [[UIImageView alloc] initWithImage:_imgLine];
        self.leftView = (UIView *)imgViewSearch;
        self.leftViewMode = UITextFieldViewModeAlways;
        //self.clearButtonMode = UITextFieldViewModeWhileEditing;//文本框有文字显示清空
        self.layer.cornerRadius = 5 ;
        self.backgroundColor = [UIColor clearColor];
        self.returnKeyType = UIReturnKeyDone;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.font = [UIFont systemFontOfSize:13];
        self.borderStyle = UITextBorderStyleNone;
        self.placeholder = holder;
        self.tintColor = kUIColorFromRGB(TextFieldtintColor);

        _passCodeFn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-85, (self.frame.size.height-34)/2, 85, 34)];
        [_passCodeFn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_passCodeFn setBackgroundColor:kUIColorFromRGB(ButtonTypeColor)];
        _passCodeFn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_passCodeFn addTarget:self action:@selector(passWordCode:) forControlEvents:UIControlEventTouchUpInside];
        [_passCodeFn setButtonNormalStyle];
        [self addSubview:_passCodeFn];
        [self underLine];
        
    }
    return self;
}


- (void)passWordCode:(UIButton *)sender{
    
    if ([self.refCodedelegate respondsToSelector:@selector(sendCode:code:)]) {
         [self.refCodedelegate sendCode:self code:sender];
    }
}

//控制搜索图片的位置，用到图片宽高
-(CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect inset = CGRectMake(bounds.origin.x+5+10, (bounds.size.height - 20) *0.5 , _imgLine.size.width, _imgLine.size.height-10);
    return inset;
}

//控制placeHolder的位置
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    //return CGRectInset(bounds, 20, 0);
    CGRect inset = CGRectMake(bounds.origin.x+35+10, bounds.origin.y, bounds.size.width -50, bounds.size.height);
    return inset;
}

//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds{
    //return CGRectInset(bounds, 50, 0);
    CGRect inset = CGRectMake(bounds.origin.x+30+10, bounds.origin.y, bounds.size.width -50, bounds.size.height);
    
    return inset;
    
}

//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    //return CGRectInset( bounds, 10 , 0 );sssss
    CGRect inset = CGRectMake(bounds.origin.x +30+10, bounds.origin.y, bounds.size.width -120+25, bounds.size.height);
    return inset;
}

//清除按钮位置
- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x +100-25, bounds.origin.y, bounds.size.width -50, bounds.size.height);
    return inset;
    
}
-(UIView*)underLine{
    if (!_underLine) {
        UIView *underLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
        underLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:underLine];
        _underLine = underLine;
    }
    return _underLine;
}



@end

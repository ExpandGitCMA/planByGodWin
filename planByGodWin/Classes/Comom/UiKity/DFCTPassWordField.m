//
//  DFCTPassWordField.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCTPassWordField.h"
#import "DFCColorDef_pch.h"
@interface DFCTPassWordField ()
@property (nonatomic,strong) UIImage *imgLine;
@property (nonatomic,weak)   UIView *underLine;
@property (nonatomic,strong) UIImageView *imgIcon;
@property (nonatomic,strong) UIButton *passWordFn;
@property (nonatomic,strong) UIButton *beginEditFn;
@end

@implementation DFCTPassWordField

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
        self.backgroundColor = [UIColor whiteColor];
        self.returnKeyType = UIReturnKeyGo;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.font = [UIFont systemFontOfSize:13];
        self.borderStyle = UITextBorderStyleNone;
        self.placeholder = holder;
        self.tintColor = kUIColorFromRGB(TextFieldtintColor);
        self.secureTextEntry = YES;//密文输入
        
        _beginEditFn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-55-30, (self.frame.size.height-20)/2, 20, 20)];
        [_beginEditFn setImage:[UIImage imageNamed:@"register_cancel"] forState:UIControlStateNormal];
        [_beginEditFn addTarget:self action:@selector(passWordEditing:) forControlEvents:UIControlEventTouchUpInside];
        [self textFieldDidEndEditing];
        [self addSubview:_beginEditFn];
        
        _passWordFn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-55, (self.frame.size.height-34)/2, 55, 34)];
        [_passWordFn setImage:[UIImage imageNamed:@"register_hide"] forState:UIControlStateNormal];
        [_passWordFn setImage:[UIImage imageNamed:@"register_display"] forState:UIControlStateSelected];
        [_passWordFn addTarget:self action:@selector(passWordAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_passWordFn];
        [self underLine];
    }
    return self;
}
- (void)passWordEditing:(UIButton *)sender{
       self.text = nil;
       [self textFieldDidEndEditing];
    if ([self.passWorddelegate respondsToSelector:@selector(redactPassWord:code:)]) {
         [self.passWorddelegate redactPassWord:self code:sender];
    }
}
- (void) deleteBackward{
    [super deleteBackward];
    if (_passWorddelegate && [_passWorddelegate respondsToSelector:@selector(deleteBackward)]) {
        [_passWorddelegate deleteBackward];
    }
}



- (void)passWordAction:(UIButton *)sender{
    if (!sender.isSelected) {
        sender.selected = YES;
          self.secureTextEntry = NO;//关闭密文输入
    }else{
        sender.selected = NO;
        self.secureTextEntry = YES;//密文输入
    }
}

-(void)textFieldBeginEditing{
    _beginEditFn.hidden = NO;
}
-(void)textFieldDidEndEditing{
    _beginEditFn.hidden = YES;
}


//控制搜索图片的位置，用到图片宽高
-(CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect inset = CGRectMake(bounds.origin.x+30, (bounds.size.height - 20) *0.5 , _imgLine.size.width, _imgLine.size.height-10);
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
    CGRect inset = CGRectMake(bounds.origin.x +30+10, bounds.origin.y, bounds.size.width -120, bounds.size.height);
    return inset;
}

//清除按钮位置
- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x +100, bounds.origin.y, bounds.size.width -50, bounds.size.height);
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

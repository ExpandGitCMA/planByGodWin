//
//  DFCClassTextField.m
//  planByGodWin
//
//  Created by 陈美安 on 16/11/18.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCClassTextField.h"
#import "DFCColorDef_pch.h"
@interface DFCClassTextField ()<UITextFieldDelegate>
@property (nonatomic,strong) UIImage *imgLine;
@property (nonatomic,strong) UIImageView *imgIcon;
@property (nonatomic,strong) UIButton *classCodeFn;
@end
@implementation DFCClassTextField

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
        self.returnKeyType = UIReturnKeyDone;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.font = [UIFont systemFontOfSize:13];
        self.borderStyle = UITextBorderStyleNone;
        self.placeholder = holder;
        self.tintColor = kUIColorFromRGB(TextFieldtintColor);
      
        UIView *under = [[UIView alloc]initWithFrame:CGRectMake(25, 0, self.frame.size.width-25, self.frame.size.height)];
        under.backgroundColor = [UIColor whiteColor];
        under.layer.cornerRadius = 5 ;
        [self addSubview:under];
        
        _classCodeFn = [[UIButton alloc] initWithFrame:CGRectMake(25, (self.frame.size.height-34)/2, self.frame.size.width-35, 34)];
        [_classCodeFn setImage:[UIImage imageNamed:@"plus_up"] forState:UIControlStateNormal];
        [_classCodeFn setImage:[UIImage imageNamed:@"plus_down"] forState:UIControlStateSelected];
        [_classCodeFn setAdjustsImageWhenHighlighted:NO];
        [_classCodeFn addTarget:self action:@selector(classCode:) forControlEvents:UIControlEventTouchUpInside];
        [_classCodeFn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self addSubview:_classCodeFn];
    }
    return self;
}

- (void)classCode:(UIButton *)sender{
    if ([self.classdelegate respondsToSelector:@selector(classCode:sender:)]) {
        [self.classdelegate classCode:self sender:sender];
    }
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
    CGRect inset = CGRectMake(bounds.origin.x +30+10, bounds.origin.y, bounds.size.width -50, bounds.size.height);
    return inset;
}

@end

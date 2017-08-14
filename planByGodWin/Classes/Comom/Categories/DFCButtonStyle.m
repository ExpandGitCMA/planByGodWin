//
//  DFCButtonStyle.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCButtonStyle.h"
#import "DFCColorDef_pch.h"

@implementation  UIButton(DFCButtonStyle)
-(void)setButtonMsgStyle{
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[kUIColorFromRGB(MsgColor) CGColor];
    self.layer.borderWidth= 1.0f;
    self.backgroundColor = kUIColorFromRGB(MsgColor);
}
-(void)setButtonNormalStyle{
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[kUIColorFromRGB(ButtonTypeColor) CGColor];
    self.layer.borderWidth= 1.0f;
    self.backgroundColor = kUIColorFromRGB(ButtonTypeColor);
}

-(void)setButtontitelSize{
    self.titleLabel.font = [UIFont systemFontOfSize:15];
}

-(void)setNavigationBarStyle{
    self.layer.cornerRadius=4.5f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[kUIColorFromRGB(LineColor) CGColor];
    self.layer.borderWidth= 0.5f;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
}

-(void)setButtonExitStyle{
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[kUIColorFromRGB(ExitButtonColor) CGColor];
    self.layer.borderWidth= 1.0f;
}

-(void)setButtonUploadStyle{
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[kUIColorFromRGB(0xa6a6a6) CGColor];
    self.layer.borderWidth= 0.5f;
}
-(void)setButtonImagelayer{
    self.layer.cornerRadius=15.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[[UIColor clearColor] CGColor];
    self.layer.borderWidth= 0.5f;
}

-(void)setButtonAlignmentRightStyle{
    [self setAdjustsImageWhenHighlighted:NO];
    [self setImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"address_select"] forState:UIControlStateSelected];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
}

-(void)setButtonPayStyle:(UInt32)color{
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
     self.layer.borderColor=[kUIColorFromRGB(color) CGColor];
    self.layer.borderWidth= 0.5f;
}
@end

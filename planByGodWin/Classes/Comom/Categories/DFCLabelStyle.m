//
//  DFCLabelStyle.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCLabelStyle.h"
#import "DFCColorDef_pch.h"
@implementation  UILabel(DFCLabelStyle)

-(void)login_register_titelStyle{
    self.font = [UIFont systemFontOfSize:18 weight:1];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = kUIColorFromRGB(TitelColor);
}

-(void)defaultStyle{
    self.font = [UIFont systemFontOfSize:15];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = kUIColorFromRGB(TitelColor);
}
-(void)classStyle{
    self.font = [UIFont systemFontOfSize:14];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = kUIColorFromRGB(ClassNameColor);
}

@end

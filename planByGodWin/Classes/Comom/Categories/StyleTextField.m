//
//  StyleTextField.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/28.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "StyleTextField.h"

@implementation UITextField(StyleTextField)
-(void)textFieldlayerStyle{
    self.layer.cornerRadius=5.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[kUIColorFromRGB(0xa6a6a6) CGColor];
    self.layer.borderWidth= 0.5f;
    
    self.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.leftViewMode = UITextFieldViewModeAlways;
}


@end

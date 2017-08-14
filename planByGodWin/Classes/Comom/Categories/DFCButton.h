//
//  DFCButton.h
//  planByGodWin
// 父类Button
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *@定义继承Button枚举类型
 */
typedef NS_ENUM(NSInteger, SubkeyButtonType){
    Subkeylogin             = 0,
    Subkeyrecord          = 1,//录播
    SubkeyUserName    = 2,//用户名称
    SubkeyUserImage    = 3,//用户头像
    SubkeyEdgeInsets    = 4,//文字和图片
    SubkeyUpload          = 5,//科目和学段
    SubkeyPay               = 6,
};
/*
 *@设置控件宽高枚举值
 */
typedef NS_ENUM(int, UniversalShowView) {
    //登陆Button
    SubkeyLoginWidth     = 300,
    SubkeyLoginHeight    = 45,
    SubkeySpace             = 310,
    
    //录播工具条
    UniversalHeight     = 45,
    UniversalSpace      = 20,//间距和起点
    UpButtonWidth       = 188,//上课
    SelectButtonWidth   = 125,//选择录播
    ClassNameWidth      = 165,
    //教师学生版本
    SubkeyUserWidth     = 205,
    SubkeyUserSpace     = 25,
};




@interface DFCButton : UIButton
@property(nonatomic,assign)SubkeyButtonType Key;
@end

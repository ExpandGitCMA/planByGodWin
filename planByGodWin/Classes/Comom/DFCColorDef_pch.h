//
//  DFCColorDef_pch.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#ifndef DFCColorDef_pch_h
#define DFCColorDef_pch_h

#import <Foundation/Foundation.h>

//rgb 转换 色值码
#define kUIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/*
 *自定义RGB颜色值枚举
 */
typedef NS_ENUM(UInt32, ColorRGBType) {
    DefaultColor             = 0xf1f1f1,
    BackTypeColor         = 0x4cc389,
    TextFieldtintColor     = 0x95c9f4,
    LineColor                 = 0x999999,
    NavbarBgColor        = 0xeaeced,
    ButtonTypeColor     = 0x4cc366,
    TitelColor                = 0x333333,
    LoginPageColor       = 0xe8e8e8,
    ExitButtonColor       = 0xff6e6e,
    ClassesColor           = 0xf2a0d5,
    LineClassColor        = 0xd6d6d6,
    ClassCodeColor     = 0x303438,
    ClassNameColor     = 0x5fb2df,
    ToolColor               = 0xb4b4b4,
    //MessgelColor         = 0xf4f4f4,
   MessgelColor         = 0xefefef,
    LinToolColor          = 0xdcdcdc,
    MsgColor              = 0x169bd5,
    /**
     add by 何米颖
     16-11-18
     颜色
     */
    BackgroundColor    = 0xf9f9f9,
    BoardLineColor     = 0xcdcdcd,
    ButtonGreenColor   = 0x4cc366,
    ButtonRedColor   = 0xf35d5a,
    ButtonBlueColor   = 0x009BD2,
    SelectColor        = 0xc3c3c3,
    NaviBackColor      = 0x525252,
    BackgroundViewColor = 0x5a5c63,
    PopColor           = 0x5B5C62,
    CollectionBackgroundColor = 0xf3f3f3,
    CoursewareTitltColor = 0x494949,
    CoursewareInfoColor = 0x999999,
    MsgBgColor = 0xf7f7f7,
    PayColor = 0xdcdcdc,
    SubTitelColor                = 0x666666,
    EnFClassColore    = 0Xf2f2f2,
};

#endif /* DFCColorDef_pch_h */

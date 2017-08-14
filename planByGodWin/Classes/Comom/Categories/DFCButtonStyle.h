//
//  DFCButtonStyle.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface   UIButton(DFCButtonStyle)
/**
 *  设置正常公用风格
 */
- (void)setButtonNormalStyle;
/**
 *  设置正常文字大小
 */
-(void)setButtontitelSize;
/**
 *  设置导航栏按钮风格
 */
-(void)setNavigationBarStyle;
/**
 *  设置登出按钮风格
 */
- (void)setButtonExitStyle;
/**
 *  设置头像按钮风格
 */
-(void)setButtonImagelayer;

-(void)setButtonMsgStyle;
-(void)setButtonUploadStyle;
-(void)setButtonAlignmentRightStyle;
-(void)setButtonPayStyle:(UInt32)color;
@end

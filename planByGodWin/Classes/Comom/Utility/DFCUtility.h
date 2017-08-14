//
//  DFCUtility.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCUtility : NSObject
/*
 电话号码校验
 */
+ (BOOL)isValidPhoneNum:(NSString *)phoneNum;

//字符串处理
+ (BOOL)isNumber:(NSString *)string;
+ (BOOL)isNumberID:(NSString *)string;
+ (BOOL)isNumberAndCharter:(NSString *)string;
//校验昵称
+ (BOOL)isIegalCharter:(NSString *)string;

/**
 add by 何米颖
 16-11-21
 学生教师
 */
+ (BOOL)isCurrentTeacher;
/*
 *@判定教师学生身份
 *@YES教师  NO 学生
 @NULL值 默认选择教师
 */
+ (BOOL)isLoginStatus;

// add by hmy
+ (NSString *)get_uuid;

@end

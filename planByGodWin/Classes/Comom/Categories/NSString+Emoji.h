//
//  NSString+Emoji.h
//  planByGodWin
//
//  Created by dfc on 2017/4/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Emoji)

/**
 判断某字符串中是否含有Emoji表情

 @param string 要判断的字符串
 @return 是否含有表情符号
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;


- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/**
 判断字符串是否纯数字
 */
+ (BOOL)isPureNumandCharacters:(NSString *)string;

/**
 判断字符串是否为整型
 */
+ (BOOL)isPureInt:(NSString *)string;
/**
 判断字符串是否为浮点型
 */
+ (BOOL)isPureFloat:(NSString *)string;

/**
 根据字符串信息生成二维码
 
 @param string 字符串信息
 @param size 二维码图片大小
 @return 二维码图片
 */
+ (UIImage *)createImgWithString:(NSString *)string size:(CGSize)size;
@end

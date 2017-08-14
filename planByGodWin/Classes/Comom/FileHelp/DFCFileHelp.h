//
//  DFCFileHelp.h
//  planByGodWin
//  通用文件操作
//  Created by DaFenQi on 16/11/15.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCFileHelp : NSObject

#pragma mark - 课件目录操作
/**
 创建本地目录

 @param code     帐号编码
 @param subjects 科目数组
 */
+ (void)configureFileSystemForCode:(NSString *)code
                          subjects:(NSArray *)subjects;

/**
  通过教师code获取根目录

 @param code 教师code

 @return 根目录
 */
+ (NSString *)pathForCode:(NSString *)code;

/**
 根据教师code,科目获取科目目录

 @param code    教师code
 @param subject 科目

 @return 科目目录
 */
+ (NSString *)pathForCode:(NSString *)code
                  subject:(NSString *)subject;

#pragma mark - 获取通用目录
/**
 doc path

 @return path
 */
+ (NSString *)documentPath;

/**
 临时文件保存路径

 @return 路径
 */
+ (NSString *)tempPath;

#pragma mark - 通用目录操作
// 目录是否存在,文件是否存在
+ (BOOL)isExistFile:(NSString *)filePath;
// 写文件
//+ (BOOL)writeFile:(NSString *)filePath;
// 删除文件
+ (BOOL)deleteFile:(NSString *)filePath;

#pragma mark - doc 目录文件操作
/*
 doc目录不应该随便存储东西,可能被拒
 存储支持离线使用的数据
 */

/**
 写文件到doc, 会被icloud备份
 
 @param fileName 文件名
 
 @return 是否成功
 */
//+ (BOOL)writeFileAtDoc:(NSString *)fileName;

/**
 删除doc目录下的文件

 @param fileName 文件名

 @return 是否成功
 */
+ (BOOL)deleteFileAtDoc:(NSString *)fileName;

/**
 不同步到icloud

 @param filePath 文件路径

 @return 是否成功
 */
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePath;

+ (NSArray *)getThumbnailNames:(NSString *)temp;

@end

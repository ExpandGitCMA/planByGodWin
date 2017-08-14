//
//  DFCBoardZipHelp.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/7.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCBoardZipHelp : NSObject

+ (NSString *)zipBoard:(NSString *)boardPath;

+ (void)unZipBoard:(NSString *)srcPath
                 destUrl:(NSString *)destPath;


/**
 压缩文件夹

 @param zipPath 压缩之后的路径
 @param directory 文件夹路径
 @return 是否压缩成功
 */
+ (BOOL)zipFileAtPath:(NSString *)zipPath withDirectory:(NSString *)directory;

@end

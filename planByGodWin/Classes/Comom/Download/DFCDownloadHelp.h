//
//  DFCDownloadHelp.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/6.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCFileModel;

@interface DFCDownloadHelp : NSObject

/**
 删除一个文件时候涉及到的sqlite操作,以及本地操作

 @param fileModel 文件模型
 */
+ (void)deleteFile:(DFCFileModel *)fileModel;

@end

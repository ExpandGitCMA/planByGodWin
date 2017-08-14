//
//  DFCFileHelp.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/15.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCFileHelp.h"
#import "DFCHeader_pch.h"

@implementation DFCFileHelp

#pragma mark - 课件目录操作

/**
 创建本地目录
 
 @param code     帐号编码
 @param subjects 科目数组
 */
+ (void)configureFileSystemForCode:(NSString *)code
                          subjects:(NSArray *)subjects {
    // doc 目录
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // 创建根目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    docsDir = [docsDir stringByAppendingPathComponent:code];
    
    BOOL isExist;
    BOOL isDir;
    isExist = [fileManager fileExistsAtPath:docsDir isDirectory:&isDir];
    
    if (!isExist || isDir) {
        
        [fileManager createDirectoryAtPath:docsDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        // 创建科目目录
        for (NSString *subjectName in subjects) {
            
            NSString *subjectDir = [docsDir stringByAppendingPathComponent:subjectName];
            isExist = [fileManager fileExistsAtPath:docsDir isDirectory:&isDir];
            
            if (!isExist || isDir) {
                [fileManager createDirectoryAtPath:subjectDir
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:nil];
            }
            
        }
        
    }
}

/**
 通过教师code获取根目录
 
 @param code 教师code
 
 @return 根目录
 */
+ (NSString *)pathForCode:(NSString *)code {
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    docsDir = [docsDir stringByAppendingPathComponent:code];
    
    return docsDir;
}

/**
 根据教师code,科目获取科目目录
 
 @param code    教师code
 @param subject 科目
 
 @return 科目目录
 */
+ (NSString *)pathForCode:(NSString *)code
                  subject:(NSString *)subject {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    docsDir = [docsDir stringByAppendingPathComponent:code];
    if (![fileManager fileExistsAtPath:docsDir]) {
        [fileManager createDirectoryAtPath:docsDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
    docsDir = [docsDir stringByAppendingPathComponent:subject];
    if (![fileManager fileExistsAtPath:docsDir]) {
        [fileManager createDirectoryAtPath:docsDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
    
    return docsDir;
}

#pragma mark - 获取通用目录

/**
 临时文件保存路径
 
 @return 路径
 */
+ (NSString *)tempPath {
    return NSTemporaryDirectory();
}

/**
 doc path
 
 @return path
 */
+ (NSString *)documentPath {
    return  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

#pragma mark - 通用目录操作

+ (BOOL)isExistFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}


// 写文件
//+ (BOOL)writeFile:(NSString *)filePath {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSFileHandle *fileHandle = [NSFileHandle ]
//    [fileManager ];
//}

// 删除文件
+ (BOOL)deleteFile:(NSString *)filePath {
    if (filePath == nil || [filePath isEqualToString:@""]) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL result;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    result = [fileManager removeItemAtPath:filePath error:&error];
    
    if (!result) {
        DEBUG_NSLog(@"%@", [error description]);
    }
    
    return result;
}

#pragma mark - doc 目录文件操作
/**
 写文件到doc, 会被icloud备份
 
 @param fileName 文件名
 
 @return 是否成功
 */
//+ (BOOL)writeFileAtDoc:(NSString *)fileName {
//
//}

/**
 删除doc目录下的文件
 
 @param fileName 文件名
 
 @return 是否成功
 */
+ (BOOL)deleteFileAtDoc:(NSString *)fileName {
    NSString *filePath = [[self.class documentPath] stringByAppendingPathComponent:fileName];
    NSError *error = nil;
    BOOL result;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    result = [fileManager removeItemAtPath:filePath error:&error];
    
    if (!result) {
        DEBUG_NSLog(@"%@", [error description]);
    }
    
    return result;
}

/**
 不同步到icloud
 
 @param filePath 文件路径
 
 @return 是否成功
 */
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [url path]]);
    
    NSError *error = nil;
    BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    
    if (!success) {
        DEBUG_NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    
    return success;
}

+ (NSArray *)getThumbnailNames:(NSString *)temp {
    NSString *boardPlistPath = [temp stringByAppendingPathComponent:@"thumbnail.plist"];
    NSData *data = [NSData dataWithContentsOfFile:boardPlistPath];
    
    NSArray *names = nil;
    if (data != nil)  {
        names = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    } else {
        names = [NSArray new];
    }
    
    return names;
}

@end

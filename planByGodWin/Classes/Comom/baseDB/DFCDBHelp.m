//
//  DFCDBHelp.m
//  DFCDB
//
//  Created by DaFenQi on 16/11/14.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCDBHelp.h"
#import "DFCHeader_pch.h"

@interface DFCDBHelp ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation DFCDBHelp

static DFCDBHelp *_dbHelp = nil;

#pragma mark - 单例
+ (DFCDBHelp *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dbHelp = [[super allocWithZone:NULL] init];
    });
    
    return _dbHelp;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [DFCDBHelp sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [DFCDBHelp sharedInstance];
}

#pragma mark - other
- (FMDatabaseQueue *)dbQueue {
    if (_dbQueue == nil) {
        // 第一次使用时创建db
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:[[self class] dbPath]];
    }
    
    return _dbQueue;
}

+ (NSString *)dbPathWithDirectoryName:(NSString *)directoryName {
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // 创建文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    docsDir = [docsDir stringByAppendingPathComponent:@"DB"];
    BOOL isExist;
    BOOL isDir;
    isExist = [fileManager fileExistsAtPath:docsDir isDirectory:&isDir];
    if (!isExist || !isDir) {
        [fileManager createDirectoryAtPath:docsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [docsDir stringByAppendingPathComponent:@"dfcDB.sqlite"];
}

+ (NSString *)dbPath {
    return [[self class] dbPathWithDirectoryName:nil];
}

@end

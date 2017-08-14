//
//  DFCBoardZipHelp.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/7.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCBoardZipHelp.h"
#import "SSZipArchive.h"
#import "DFCBoardCareTaker.h"

@implementation DFCBoardZipHelp

+ (NSString *)zipBoard:(NSString *)boardPath {
    NSString *name = [boardPath lastPathComponent];
    NSString *basePath = [boardPath stringByDeletingLastPathComponent];
    NSString *zipPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", name, kZipFileType]];
    // 压缩
    if ([SSZipArchive createZipFileAtPath: zipPath
                  withContentsOfDirectory: boardPath] ) {
        DEBUG_NSLog(@"success");
    } else {
        DEBUG_NSLog(@"failed");
    }
    
    return zipPath;
}

+ (void)unZipBoard:(NSString *)srcPath
                 destUrl:(NSString *)destPath {
    // 解压
    if ([SSZipArchive unzipFileAtPath:srcPath toDestination: destPath]) {
        DEBUG_NSLog(@"success");
        //[[DFCBoardCareTaker sharedCareTaker] addZipSource:@"boards_0"];
    } else {
        DEBUG_NSLog(@"failed");
    }
}

+ (BOOL)zipFileAtPath:(NSString *)zipPath withDirectory:(NSString *)directory{
    return [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:directory];
}

@end

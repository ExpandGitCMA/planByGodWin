//
//  DFCDownloadDemo.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/17.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCDownloadDemo.h"
#import "DFCFileHelp.h"
#import "DFCFileModel.h"
#import "DFCDownloadManager.h"
#import "DFCHeader_pch.h"

@implementation DFCDownloadDemo

+ (void)demo {
    /*
    NSString *filePath = [DFCFileHelp documentPath];
    NSString *tempPath = [DFCFileHelp tempPath];
     */
    
    // 开始一个任务
    DFCFileModel *fileModel = [[DFCFileModel alloc] init];
    fileModel.fileUrl = @"http://download.dafenci.com/teacher_20002.ipa";
    fileModel.fileSize = @"10780925";
    fileModel.fileName = @"teacher_20002.ipa";
    fileModel.finalPath = [DFCFileHelp documentPath];
    fileModel.tempPath = [DFCFileHelp tempPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([fileModel needDownload]) {
            [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
        }
    });
    
    // 开始另一个任务
    // 开始一个任务
    DFCFileModel *fileModel1 = [[DFCFileModel alloc] init];
    fileModel1.fileUrl = @"http://download.dafenci.com/student_20301.ipa";
    fileModel1.fileSize = @"4845191";
    fileModel1.fileName = @"student_20301.ipa";
    fileModel1.finalPath = [DFCFileHelp documentPath];
    fileModel1.tempPath = [DFCFileHelp tempPath];
    
    DEBUG_NSLog(@"%@", fileModel1.finalPath);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DFCDownloadManager sharedManager] addDownloadTask:fileModel1];
    });
    // 开始一个任务
//    DFCFileModel *fileModel3 = [[DFCFileModel alloc] init];
//    fileModel3.fileUrl = @"http://download.dafenci.com/teacher_20003.ipa";
//    fileModel3.fileSize = @"11220574";
//    fileModel3.fileName = @"teacher_20003.ipa";
//    fileModel3.finalPath = [DFCFileHelp documentPath];
//    fileModel3.tempPath = [DFCFileHelp tempPath];
//    
//    [[DFCDownloadManager sharedManager] addDownloadTask:fileModel3];
    
    // 开始一个任务
    DFCFileModel *fileModel4 = [[DFCFileModel alloc] init];
    fileModel4.fileUrl = @"http://download.dafenci.com/stu.apk";
    fileModel4.fileSize = @"6173494";
    fileModel4.fileName = @"stu.apk";
    fileModel4.finalPath = [DFCFileHelp documentPath];
    fileModel4.tempPath = [DFCFileHelp tempPath];
    
    [[DFCDownloadManager sharedManager] addDownloadTask:fileModel4];
}

@end

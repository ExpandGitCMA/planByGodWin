//
//  DFCDownloadHelp.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/6.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCDownloadHelp.h"
#import "DFCFileModel.h"
#import "DFCFileHelp.h"
#import "DFCCoursewareLibraryModel.h"

@implementation DFCDownloadHelp

+ (void)deleteFile:(DFCFileModel *)fileModel {
    // 删除文件记录
    fileModel.fileState = kDFCCurrentFileStateNotStarted;
    fileModel.isCourseLibraryCourse = kDFCIsCourseLibraryCourseTrue;
    [fileModel deleteObject];
    
    // 更新文件夹信息
    DFCFileModel *fileDir = [[DFCFileModel findByFormat:@"WHERE subjectCode = '%@' AND fileType = 0 AND userCode = '%@'", fileModel.subjectCode, fileModel.userCode] firstObject];
    
    // 文件夹对应文件
    NSArray *files = [DFCFileModel findByFormat:@"WHERE subjectCode = '%@' AND fileType = 1 and userCode = '%@' and fileState = 1", fileModel.subjectCode, fileModel.userCode];
    
    fileDir.coursewareCount = [NSString stringWithFormat:@"%li", files.count];
    [fileDir update];
    
    // 更新资源库
    DFCCoursewareLibraryModel *model = [DFCCoursewareLibraryModel findByPrimaryKey:fileModel.code];
    model.fileState = kDFCCurrentFileStateNotStarted;
    [model update];
    
    // 删除本地文件
    [DFCFileHelp deleteFile:fileModel.finalPath];
}

@end

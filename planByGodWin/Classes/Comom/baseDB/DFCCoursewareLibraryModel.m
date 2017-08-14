//
//  DFCCoursewareLibraryModel.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/26.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCCoursewareLibraryModel.h"

@implementation DFCCoursewareLibraryModel

+ (instancetype)dataWithJson:(NSDictionary *)dict {
    DFCCoursewareLibraryModel *fileModel = [DFCCoursewareLibraryModel new];
    // 目录
    fileModel.subjectCode = dict[@"subjectCode"];
    fileModel.subjectName = dict[@"subjectName"];
    fileModel.coursewareCount = dict[@"coursewareAmount"];
    
    // userCode
   //fileModel.userCode = DFCUserDefaultManager.currentCode;
    fileModel.coursewareCode = dict[@"coursewareCode"];
    
    // code 采取拼接usercode + code
    if (fileModel.coursewareCount) {
        fileModel.code = [NSString stringWithFormat:@"%@%@",fileModel.userCode, dict[@"subjectCode"]];
    } else {
        fileModel.code = [NSString stringWithFormat:@"%@%@",fileModel.userCode, dict[@"coursewareCode"]];
    }
    
    // 文件
    fileModel.fileName = dict[@"coursewareName"];
    
    fileModel.thumbnailUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, dict[@"thumbUrl"]];
    
    if (dict[@"url"]) {
        fileModel.fileUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, dict[@"url"]];
    }
    if (fileModel.fileUrl) {
        NSString *docType = [fileModel.fileUrl lastPathComponent];
        if ([docType hasSuffix:@"pptx"]) {
            fileModel.docType = kDFCDocTypePPTX;
        } else if([docType hasSuffix:@"ppt"]) {
            fileModel.docType = kDFCDocTypePPT;
        } else {
            fileModel.docType = kDFCDocTypeBoard;
        }
    }
    
    fileModel.content = dict[@"content"];
        
    // 时间
    fileModel.createDate = [DFCDateHelp currentDate];
    
    // 后台session
    fileModel.backgroundSessionId = [NSString stringWithFormat:@"com.planDFC.planByGodWin.%@%@", fileModel.userCode, fileModel.code];
    
    return fileModel;
}

- (DFCFileModel *)fileModel {
    DFCFileModel *fileModel = [DFCFileModel new];
    // 目录
    fileModel.subjectCode = self.subjectCode;
    fileModel.subjectName = self.subjectName;
    fileModel.coursewareCount = self.coursewareCount;
    
    // userCode
   // fileModel.userCode = DFCUserDefaultManager.currentCode;
    fileModel.coursewareCode = self.coursewareCode;
    fileModel.code = self.code;

    fileModel.fileName = self.fileName;
    fileModel.thumbnailUrl = self.thumbnailUrl;
    fileModel.fileUrl = self.fileUrl;
    fileModel.docType = self.docType;
    fileModel.content = self.content;
    // 时间
    fileModel.createDate = [DFCDateHelp currentDate];

    fileModel.teacherCode = self.userCode;
    fileModel.fileType = kDFCFileTypeFile;
    fileModel.fileState = kDFCCurrentFileStateNotComplete;
    
    // 后台session
    fileModel.backgroundSessionId = [NSString stringWithFormat:@"com.planDFC.planByGodWin.%@%@", fileModel.userCode, fileModel.code];
    
    return fileModel;
}

+ (NSArray *)propertiesNotInTable {
    return @[];
}

@end

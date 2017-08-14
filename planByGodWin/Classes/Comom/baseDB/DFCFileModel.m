//
//  DFCFileModel.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCFileModel.h"
#import "DFCRequest_Url.h"
//#import "DFCDBHelp.h"

@implementation DFCFileModel

+ (instancetype)dataWithJson:(NSDictionary *)dict {
    DFCFileModel *fileModel = [DFCFileModel new];
    // 目录
    fileModel.subjectCode = dict[@"subjectCode"];
    fileModel.subjectName = dict[@"subjectName"];
    fileModel.coursewareCount = dict[@"coursewareAmount"];
    fileModel.teacherCode = dict[@"teacherCode"];
    
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

+ (NSArray *)propertiesNotInTable {
    return @[@"canEdit", @"isSelected"];
}

/**
 判断该fileModel是否需要更新
 
 @return bool
 */
- (BOOL)needDownload {
    DFCFileModel *fileModel = [[DFCFileModel findByFormat:@"WHERE code=%@", self.code] firstObject];
    // 版本一样不需要更新
    if ([fileModel.version isEqualToString:self.version]) {
        // 下载是完整的
        if (fileModel.fileState == kDFCCurrentFileStateComplete) {
            return NO;
        }
    }
    
    // 否则更新
    return YES;
}

@end

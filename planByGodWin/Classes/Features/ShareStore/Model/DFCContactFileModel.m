//
//  DFCContactFileModel.m
//  planByGodWin
//
//  Created by dfc on 2017/6/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCContactFileModel.h"

@implementation DFCContactFileModel

+ (instancetype)contactFileModelWithDict:(NSDictionary *)dict{
    
    DFCContactFileModel *fileModel = [[DFCContactFileModel alloc]init];
    fileModel.fileID = dict[@"id"];
    fileModel.fileName = dict[@"fileName"];
    fileModel.fileType = [dict[@"fileType"] integerValue];
    fileModel.fileUrl = dict[@"filePath"];
    
    fileModel.fileSize = kDFCFileSize([dict[@"fileSize"] longValue]);
    
    return fileModel;
}

+ (instancetype)contactedFileModelWithDict:(NSDictionary *)dict{
    
    DFCContactFileModel *fileModel = [[DFCContactFileModel alloc]init];
    fileModel.fileID = dict[@"id"];
    fileModel.fileName = dict[@"videoName"];
    fileModel.fileUrl = dict[@"videoUrl"];
    fileModel.fileCoursewareCode = dict[@"coursewareCode"];
    
    return fileModel;
}

@end

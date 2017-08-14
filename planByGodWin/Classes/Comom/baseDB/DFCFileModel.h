//
//  DFCFileModel.h
//  planByGodWin
//  下载成功的课件
//  Created by DaFenQi on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

/**
 为了方便处理将文件夹与文件模型统一存入本地数据库
 
 - kDFCFileTypeDir: 文件文件夹
 */
typedef NS_ENUM(NSUInteger, kDFCFileType) {
    kDFCFileTypeDir = 0,    // 文件夹
    kDFCFileTypeFile = 1,   // 文件
};

typedef NS_ENUM(NSUInteger, kDFCDocType) {
    kDFCDocTypePPT = 0,     // ppt
    kDFCDocTypeBoard = 1,   // 画板
    kDFCDocTypePPTX = 2     // pptx
};

typedef NS_ENUM(NSUInteger, kDFCCurrentFileState) {
    kDFCCurrentFileStateNotComplete = 0, // 未完成
    kDFCCurrentFileStateComplete = 1,    // 完成
    kDFCCurrentFileStateNotStarted = 2   // 未开始下载
};

typedef NS_ENUM(NSUInteger, kDFCDownLoadState) {
    kDFCDownLoadStateDownloading = 0,    // 默认
    kDFCDownLoadStateWillDownload = 1,   // 等待下载
    kDFCDownLoadStateStopDownload = 2,   // 停止下载
};

typedef NS_ENUM(NSUInteger, kDFCIsCourseLibraryCourse) {
    kDFCIsCourseLibraryCourseTrue,      // 课件库中
    kDFCIsCourseLibraryCourseFalse,     // 不在课件库
};

@interface DFCFileModel : DFCDBModel

@property (nonatomic, copy) NSString *code;     // 课件编码
@property (nonatomic, copy) NSString *coursewareCode; // 课件编码
@property (nonatomic, copy) NSString *userCode; // 用户code
@property (nonatomic, copy) NSString *teacherCode; // 教师编码

#pragma mark - 科目
@property (nonatomic, copy) NSString *subjectCode; // 科目编码
@property (nonatomic, copy) NSString *subjectName; // 科目名称
@property (nonatomic, copy) NSString *coursewareCount; // 课程数目

#pragma mark - 文件
@property (nonatomic, copy) NSString *fileUrl; // 文件地址
@property (nonatomic, copy) NSString *thumbnailUrl; // 缩略图
@property (nonatomic, copy) NSString *content;  // 文件描述
@property (nonatomic, copy) NSString *fileName; // 文件名

@property (nonatomic, copy) NSString *fileSize; // 文件大小
@property (nonatomic, copy) NSString *fileReceivedSize; // 当前收到的文件大小
@property (nonatomic, copy) NSString *finalPath; // 最终文件存储地址

@property (nonatomic, copy) NSString *createDate; // 创建日期
@property (nonatomic, copy) NSString *updateDate; // 更新日期

@property (nonatomic, assign) NSUInteger downloadState; // 下载状态
@property (nonatomic, assign) NSUInteger fileState; // 是否下载成功
@property (nonatomic, assign) NSUInteger docType;   // ppt还是
@property (nonatomic, assign) NSUInteger isCourseLibraryCourse; // 是否课件库的课件
@property (nonatomic, assign) NSUInteger fileType;  // 文件还是文件夹


#pragma mark - 预留
@property (nonatomic, copy) NSString *classCode; // 班级编码
@property (nonatomic, copy) NSString *version; // 文件版本,通过version判断是否更新
@property (nonatomic, copy) NSString *tempPath; // 文件存储的临时文件路径

#pragma mark - 不需要存sqlite
@property (nonatomic, assign) BOOL isSelected;      // 是否选中
@property (nonatomic, assign) BOOL canEdit;         // 是否可编辑
@property (nonatomic, copy) NSString *backgroundSessionId; // 后台session

/**
 判断该fileModel是否需要下载
 
 @return bool
 */
- (BOOL)needDownload;

// 不需要存入表的字段
+ (NSArray *)propertiesNotInTable;
+ (instancetype)dataWithJson:(NSDictionary *)dict;

@end

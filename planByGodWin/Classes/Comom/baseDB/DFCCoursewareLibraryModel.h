//
//  DFCCoursewareLibraryModel.h
//  planByGodWin
//  课件库的课件
//  Created by DaFenQi on 16/11/26.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCDBModel.h"
#import "DFCFileModel.h"

@interface DFCCoursewareLibraryModel : DFCDBModel

@property (nonatomic, copy) NSString *code;     // 主键
@property (nonatomic, copy) NSString *coursewareCode; // 课件编码
@property (nonatomic, copy) NSString *userCode; // 用户code

@property (nonatomic, copy) NSString *subjectCode; // 科目编码
@property (nonatomic, copy) NSString *subjectName; // 科目名称
@property (nonatomic, copy) NSString *coursewareCount; // 课程数目

@property (nonatomic, copy) NSString *thumbnailUrl; // 缩略图
@property (nonatomic, copy) NSString *content;  // 文件描述
@property (nonatomic, copy) NSString *fileName; // 文件名
@property (nonatomic, copy) NSString *fileUrl; // 文件地址
@property (nonatomic, copy) NSString *fileSize; // 文件大小
@property (nonatomic, copy) NSString *fileReceivedSize; // 当前收到的文件大小

@property (nonatomic, copy) NSString *finalPath; // 最终文件存储地址
@property (nonatomic, copy) NSString *createDate; // 创建日期
@property (nonatomic, copy) NSString *updateDate; // 更新日期

@property (nonatomic, assign) NSUInteger docType;   // ppt还是
@property (nonatomic, assign) NSUInteger fileType;  // 文件还是文件夹
@property (nonatomic, assign) NSUInteger fileState;     // 是否下载成功

#pragma mark - 预留字段
@property (nonatomic, copy) NSString *version; // 文件版本,通过version判断是否更新
@property (nonatomic, copy) NSString *classCode; // 班级编码

@property (nonatomic, copy) NSString *backgroundSessionId; // 后台session

// 不需要存入表的字段
+ (NSArray *)propertiesNotInTable;
+ (instancetype)dataWithJson:(NSDictionary *)dict;

- (DFCFileModel *)fileModel;

@end

//
//  DFCURLSessionUploadTask.h
//  planByGodWin
//
//  Created by zeros on 17/1/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCCoursewareInfo;
@class DFCURLSessionUploadTask;

@protocol DFCURLSessionUploadTaskDelegate <NSObject>

@required
- (void)taskFailed:(DFCURLSessionUploadTask *)task;
- (void)taskStarted:(DFCURLSessionUploadTask *)task;
- (void)taskFinished:(DFCURLSessionUploadTask *)task;

@end

typedef void (^kDFCUploadProgressBlock)(float);
typedef void (^kDFCUploadBlock)(float, NSString *);  // 进度上传速度
typedef void (^kDFCUploadLeftTimeBlock)(NSString *); // 剩余时间
typedef void (^kDFCUploadFinishedBlock)(void); // 上传完成一个任务监听

@interface DFCURLSessionUploadTask : NSObject

@property (nonatomic, strong) NSURLSessionUploadTask *backgroundTask; // 后台上传任务
@property (nonatomic, copy) NSURL *url; // 文件url
@property (nonatomic, strong) DFCCoursewareInfo *coursewareInfo; // 课件信息
@property (nonatomic, assign) BOOL isExcuting; // 正在上传否
@property (nonatomic, assign) BOOL isFinished; // 上传完成

@property (nonatomic, weak) id <DFCURLSessionUploadTaskDelegate>delegate; // 代理

@property (nonatomic, copy) kDFCUploadProgressBlock progressBlock; // 进度回调
@property (nonatomic, copy) kDFCUploadBlock UploadBlock; // 速度回调
@property (nonatomic, copy) kDFCUploadBlock UploadBlock1; // 速度回调
@property (nonatomic, copy) kDFCUploadLeftTimeBlock leftTimeBlock; // 剩余时间回调
@property (nonatomic, copy) kDFCUploadFinishedBlock finishedBlock; // 上传完成回调

- (instancetype)initWithUrl:(NSURL *)url;
- (void)startUpload;
- (void)stopUpload;
- (void)cancelUpload;

@end

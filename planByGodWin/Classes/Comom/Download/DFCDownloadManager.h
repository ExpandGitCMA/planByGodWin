//
//  DFCDownloadManager.h
//  planByGodWin
//  下载管理类,可以看做一个下载管理中心
//  Created by DaFenQi on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCFileModel;
@class DFCURLSessionDownloadTask;
@class DFCDownloadManager;

@protocol DFCDownloadManagerDelegate <NSObject>

@optional
- (void)taskDidStarted:(DFCURLSessionDownloadTask *)task;
- (void)taskDidFinished:(DFCURLSessionDownloadTask *)task;
- (void)taskDidFailed:(DFCURLSessionDownloadTask *)task;
- (void)task:(DFCURLSessionDownloadTask *)task progress:()progress;

@end

@interface DFCDownloadManager : NSObject

@property (nonatomic, copy) NSString *status;    //  标识是否正在下载
@property (nonatomic, assign) NSUInteger maxCount; // 单次最多下载任务
@property (nonatomic, weak) id<DFCDownloadManagerDelegate> downloadDelegate; // 下载代理

@property (atomic, strong, readonly) NSMutableArray  *downinglist;  // 下载列表（包括下载中、等待下载的任务）
@property (atomic, strong, readonly) NSMutableArray  *filelist;
@property (atomic, strong, readonly) NSMutableArray *finishedList;

+ (instancetype)sharedManager;

- (DFCURLSessionDownloadTask *)addDownloadTask:(DFCFileModel *)file;

#pragma mark - 单个操作

/**
 停止一个任务

 @param task task
 */
- (void)stopTask:(DFCURLSessionDownloadTask *)task;

/**
 恢复一个任务

 @param task task
 */
- (void)resumeTask:(DFCURLSessionDownloadTask *)task;

/**
 删除一个任务

 @param task task
 */
- (void)deleteTask:(DFCURLSessionDownloadTask *)task;

/**
 删除下载成功的任务
 
 @param task task
 */
- (void)deleteFinishedTask:(DFCURLSessionDownloadTask *)task;


#pragma mark - 批量操作
/**
 开始所有任务
 */
- (void)startAllDownloadTask;

/**
 停止所有任务
 */
- (void)pauseAllDownloadTask;

/**
 删除所有任务
 */
- (void)deleteAllDownLoadTask;

- (void)clearAllTask;

// add G    删除单个下载任务
- (void)deletetaskWithUrl:(NSString *)url;

@end

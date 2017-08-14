//
//  DFCURLSessionDownloadTask.h
//  planByGodWin
//  一个下载任务
//  Created by DaFenQi on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCFileModel;
@class DFCURLSessionDownloadTask;

@protocol DFCURLSessionDownloadTaskDelegate <NSObject>

@required
- (void)taskFailed:(DFCURLSessionDownloadTask *)task;
- (void)taskStarted:(DFCURLSessionDownloadTask *)task;
- (void)taskFinished:(DFCURLSessionDownloadTask *)task;

@end

typedef void (^kDFCDownloadProgressBlock)(float);
typedef void (^kDFCDownloadBlock)(float, NSString *);  // 进度下载速度
typedef void (^kDFCDownloadLeftTimeBlock)(NSString *); // 剩余时间
typedef void (^kDFCDownloadFinishedBlock)(void); // 下载完成一个任务监听
typedef void (^kDFCDownloadFinishedWithUrlBlock)(NSString *fileURL,NSString *fileCode);    // 下载成功之后回调fileUrl

@interface DFCURLSessionDownloadTask : NSObject
@property (nonatomic, assign) BOOL isEnd;   // 任务是否结束
@property (nonatomic, strong) NSURLSessionDownloadTask *backgroundTask; // 后台下载任务
@property (nonatomic, copy) NSData *particalData; // 当前任务下载的数据,断点续传
@property (nonatomic, copy) NSURL *url; // 文件url
@property (nonatomic, strong) DFCFileModel *fileModel; // 文件信息
@property (nonatomic, assign) BOOL isExcuting; // 正在下载否
@property (nonatomic, assign) BOOL isFinished; // 下载完成

@property (nonatomic, weak) id <DFCURLSessionDownloadTaskDelegate>delegate; // 代理

@property (nonatomic, copy) kDFCDownloadProgressBlock progressBlock; // 进度回调
@property (nonatomic, copy) kDFCDownloadBlock downloadBlock; // 速度回调
@property (nonatomic, copy) kDFCDownloadBlock downloadBlock1; // 速度回调
@property (nonatomic, copy) kDFCDownloadLeftTimeBlock leftTimeBlock; // 剩余时间回调
@property (nonatomic, copy) kDFCDownloadFinishedBlock finishedBlock; // 下载完成回调

@property (nonatomic, copy) kDFCDownloadFinishedWithUrlBlock urlBlock;    // 下载完成回调fileUrl


- (instancetype)initWithUrl:(NSURL *)url;
- (void)startDownload;
- (void)stopDownload;
- (void)cancelDownload;

@end

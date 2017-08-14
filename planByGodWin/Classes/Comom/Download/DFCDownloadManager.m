//
//  DFCDownloadManager.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCDownloadManager.h"
#import "DFCFileModel.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCCoursewareLibraryModel.h"

@interface DFCDownloadManager () <DFCURLSessionDownloadTaskDelegate> {
    
    DFCFileModel *_fileInfo; // 当前的文件信息
}

@end

@implementation DFCDownloadManager

static DFCDownloadManager *_manager = nil;

#pragma mark - 单例

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init];
    });
    
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [DFCDownloadManager sharedManager];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [DFCDownloadManager sharedManager];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // 默认一次只能下载5个任务
        _maxCount = 100;
        
        _filelist = [NSMutableArray new];
        _downinglist = [NSMutableArray new];
        _finishedList = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - session


#pragma mark - 任务管理

/**
 添加一个下载任务
 
 @param file file
 */
- (DFCURLSessionDownloadTask *)addDownloadTask:(DFCFileModel *)file {
    // 判断任务是否存在
    BOOL isTaskExist = NO;
//    for (int i = (int)self.filelist.count - 1; i >= 0; i--) {
//        DFCFileModel *fileModel = self.filelist[i];
//        if ([fileModel.code isEqualToString:file.code]) {
//            isTaskExist = YES;
//        }
//    }
    
    for (DFCURLSessionDownloadTask *downloadTask in self.downinglist) {
        if ([[NSURL URLWithString:file.fileUrl].absoluteString isEqualToString:downloadTask.url.absoluteString]) {
            isTaskExist = YES;
        }
    }
    
    if (isTaskExist) {
        return nil;
    } else {
        // 判断是否有文件存在,有则删除本地文件
        DFCURLSessionDownloadTask *task = [[DFCURLSessionDownloadTask alloc] initWithUrl:[NSURL URLWithString:file.fileUrl]];
        task.fileModel = file;
        task.delegate = self;
        
        // 最新加入的放在最前面
//        [self.filelist insertObject:file atIndex:0];
//        [self.downinglist insertObject:task atIndex:0];
        [self.filelist addObject:file];
        [self.downinglist addObject:task];
        
        [self startLoad];
        
        // 发送通知刷新页面
        [DFCNotificationCenter postNotificationName:DFC_NEWTASK_NOTIFICATION object:nil];
        
        return task;
    }
}

/**
 控制下载任务数算法
 */
- (void)startLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        __block NSUInteger num = 0;
        NSUInteger max = _maxCount;
        
        // 多余的任务设置将要下载状态
        //        [_filelist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //            DFCFileModel *fileModel = (DFCFileModel*)obj;
        //            fileModel.downloadState = kDFCDownLoadStateWillDownload;
        //            num++;
        //            if (num <= max) {
        //                fileModel.downloadState = kDFCDownLoadStateDownloading;
        //            }
        //        }];
        
        if (_filelist.count == 9) {
            
        }
        
        // 下载控制机制
        // 若num < max 的话 继续下载
        if (num < max) {
            [_filelist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DFCFileModel *fileModel = (DFCFileModel*)obj;
                if (fileModel.downloadState == kDFCDownLoadStateDownloading) {
                    if (num >= max) {
                        // 若当前下载数量大于maxcount暂停
                        fileModel.downloadState = kDFCDownLoadStateWillDownload;
                    } else {
                        // 统计当前下载数量
                        num++;
                    }
                }
            }];
        }
        
        // 不足最大下载数量,自动添加任务
        [_filelist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DFCFileModel *fileModel = (DFCFileModel *)obj;
            
            if (fileModel.downloadState == kDFCDownLoadStateWillDownload) {
                if (num >= max) {
                    *stop = YES;
                } else {
                    fileModel.downloadState = kDFCDownLoadStateDownloading;
                }
                
                num++;
            }
        }];
        
        // 下载任务
        [_downinglist enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
            DFCURLSessionDownloadTask *task = (DFCURLSessionDownloadTask *)obj;
            if (task.fileModel.downloadState == kDFCDownLoadStateDownloading) {
                if (!task.isExcuting) {
                    // 开始任务
                    [task startDownload];
                    // 存入本地数据库
                    [task.fileModel save];
                }
            } else if (task.fileModel.downloadState == kDFCDownLoadStateWillDownload) {
                if (task.isExcuting) {
                    [task stopDownload];
                }
            }
        }];
    });
}

#pragma mark - 单个操作

/**
 停止一个任务
 
 @param task task
 */
- (void)stopTask:(DFCURLSessionDownloadTask *)task {
    NSInteger max = self.maxCount;
    
    // 暂停下载任务
    if (task) {
        if (task.isExcuting) {
            [task stopDownload];
        }
    }
    
    // 将要暂定任务标记为stop
    DFCFileModel *fileModel = task.fileModel;
    for (DFCFileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileModel.fileName]) {
            file.downloadState = kDFCDownLoadStateStopDownload;
            break;
        }
    }
    
    NSInteger downingcount = 0;
    
    // 计算正在下载的任务downingcount
    for (DFCFileModel *file in _filelist) {
        if (file.downloadState == kDFCDownLoadStateDownloading) {
            downingcount++;
        }
    }
    
    // 若还有任务,则添加到正在下载队列
    if (downingcount < max) {
        for (DFCFileModel *file in _filelist) {
            if (file.downloadState == kDFCDownLoadStateWillDownload){
                file.downloadState = kDFCDownLoadStateDownloading;
                break;
            }
        }
    }
    
    // 真正下载操作
    [self startLoad];
}

/**
 恢复一个任务
 
 @param task task
 */
- (void)resumeTask:(DFCURLSessionDownloadTask *)task {
    NSInteger max = _maxCount;
    NSInteger downingcount = 0;
    NSInteger indexmax = -1;
    
    DFCFileModel *fileModel = task.fileModel;
    // 计算当前正在下载的任务数, 取出加入index
    for (DFCFileModel *file in _filelist) {
        if (file.downloadState == kDFCDownLoadStateDownloading) {
            downingcount++;
            if (downingcount == max) {
                indexmax = [_filelist indexOfObject:file];
            }
        }
    }
    
    // 若当前下载任务数最大,则停止最后一个任务
    if (downingcount == max) {
        DFCFileModel *fileModel = [_filelist objectAtIndex:indexmax];
        if (fileModel.downloadState == kDFCDownLoadStateDownloading) {
            fileModel.downloadState = kDFCDownLoadStateWillDownload;
        }
    }
    
    
    // 加入任务
    for (DFCFileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileModel.fileName]) {
            file.downloadState = kDFCDownLoadStateDownloading;
        }
    }
    
    // 重新开始此下载
    [self startLoad];
}

/**
 删除一个任务
 
 @param task task
 */
- (void)deleteTask:(DFCURLSessionDownloadTask *)task {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    //[params SafetySetObject:DFCUserDefaultManager.currentCode forKey:@"code"];
    [params SafetySetObject:task.fileModel.coursewareCode forKey:@"coursewareCode"];
    
    NSString *urlPath = nil;
    if ([DFCUtility isCurrentTeacher]) {
        urlPath = NULL;
    } else {
        urlPath = NULL;
    }
    
    [[HttpRequestManager sharedManager] requestPostWithPath:urlPath params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self p_removeTask:task];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self p_removeTask:task];
            });
        }
    }];
    
    //self.count = [_filelist count];
}

- (void)p_removeTask:(DFCURLSessionDownloadTask *)task {
    [DFCDownloadHelp deleteFile:task.fileModel];
    
    // 删除任务
    [_filelist removeObject:task.fileModel];
    [_downinglist removeObject:task];
    
    BOOL isExecuting = NO;
    
    // 暂停任务
    if (task) {
        if (task.isExcuting) {
            [task cancelDownload];
        }
        task = nil;
        task.backgroundTask = nil;
        isExecuting = YES;
    }
    
    // 继续下载
    if (isExecuting) {
        [self startLoad];
    }
    
    [DFCNotificationCenter postNotificationName:DFC_DOWNLOADTASK_DELETE_NOTIFICATION object:nil];
}

/**
 删除下载成功的任务
 
 @param task task
 */
- (void)deleteFinishedTask:(DFCURLSessionDownloadTask *)task {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    //[params SafetySetObject:DFCUserDefaultManager.currentCode forKey:@"code"];
    [params SafetySetObject:task.fileModel.coursewareCode forKey:@"coursewareCode"];
    
    NSString *urlPath = nil;
    if ([DFCUtility isCurrentTeacher]) {
        urlPath = NULL;
    } else {
        urlPath = NULL;
    }
    
    [[HttpRequestManager sharedManager] requestPostWithPath:urlPath params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self p_removeFiniehedTask:task];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self p_removeFiniehedTask:task];
            });
            DEBUG_NSLog(@"%@", obj);
        }
    }];
}

- (void)p_removeFiniehedTask:(DFCURLSessionDownloadTask *)task {
    [DFCDownloadHelp deleteFile:task.fileModel];
    
    [_finishedList removeObject:task];
    
    [DFCNotificationCenter postNotificationName:DFC_DOWNLOADTASK_DELETE_NOTIFICATION object:nil];
}

#pragma mark - 批量操作
/**
 开始所有任务
 */
- (void)startAllDownloadTask {
    for (DFCURLSessionDownloadTask *task in _downinglist) {
        if(task) {
            if (task.isExcuting) {
                [task stopDownload];
            }
        }
        
        DFCFileModel *fileInfo = task.fileModel;
        fileInfo.downloadState = kDFCDownLoadStateDownloading;
    }
    
    // 开始下载
    [self startLoad];
}

/**
 停止所有任务
 */
- (void)pauseAllDownloadTask {
    for (DFCURLSessionDownloadTask *task in _downinglist) {
        if(task) {
            if (task.isExcuting) {
                [task stopDownload];
            }
        }
        
        DFCFileModel *fileInfo = task.fileModel;
        fileInfo.downloadState = kDFCDownLoadStateStopDownload;
    }
    
    [self startLoad];
}

/**
 删除所有任务
 */
- (void)deleteAllDownLoadTask {
    [_downinglist enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        DFCURLSessionDownloadTask *task = (DFCURLSessionDownloadTask *)obj;
        if(task) {
            if (task.isExcuting) {
                [task stopDownload];
            }
            task = nil;
        }
        
        DFCFileModel *fileInfo = task.fileModel;
        NSString *path = fileInfo.tempPath;;
        
        BOOL result = [fileManager removeItemAtPath:path error:&error];
        
        if(!result) {
            DEBUG_NSLog(@"%@",[error description]);
        }
    }];
    
    [_downinglist removeAllObjects];
    [_filelist removeAllObjects];
}

#pragma mark - DFCURLSessionDownloadTaskDelegate
- (void)taskFailed:(DFCURLSessionDownloadTask *)task {
    if (task) {
        if (task.isExcuting) {
            [task stopDownload];
        }
    }
    
    DFCFileModel *fileInfo = task.fileModel;
    fileInfo.downloadState = kDFCDownLoadStateStopDownload;
    for (DFCFileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.downloadState = kDFCDownLoadStateStopDownload;
        }
    }
    
    //[self startLoad];
    
    if ([self.downloadDelegate respondsToSelector:@selector(taskDidFailed:)]) {
        [self.downloadDelegate taskDidFailed:task];
    }
}

- (void)taskStarted:(DFCURLSessionDownloadTask *)task {
    if ([self.downloadDelegate respondsToSelector:@selector(taskDidStarted:)]) {
        [self.downloadDelegate taskDidFinished:task];
    }
}

- (void)taskFinished:(DFCURLSessionDownloadTask *)task {
    DFCFileModel *fileInfo = task.fileModel;
    
    // 更新表字段
    fileInfo.fileState = kDFCCurrentFileStateComplete;
    [fileInfo update];
    
    // 下载记录
    //[_finishedList addObject:task];
    
    // 最新下载的放在最前面
    [_finishedList insertObject:task atIndex:0];
    
    // 移除任务
    dispatch_async(dispatch_get_main_queue(), ^{
        [_filelist removeObject:fileInfo];
        [_downinglist removeObject:task];
        
        [self startLoad];
    });
    
    if([self.downloadDelegate respondsToSelector:@selector(taskFinished:)]) {
        [self.downloadDelegate taskDidFinished:task];
    }
}

// add G    删除单个下载任务
- (void)deletetaskWithUrl:(NSString *)url{
    
    [self.downinglist enumerateObjectsUsingBlock:^(DFCURLSessionDownloadTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[NSString stringWithFormat:@"%@%@",BASE_UPLOAD_URL,url] isEqualToString:obj.fileModel.fileUrl]) {
            [obj cancelDownload];
            [self.downinglist removeObject:obj];
            obj = nil;
        }
    }];
}

@end

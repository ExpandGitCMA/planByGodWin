//
//  DFCURLSessionDownloadTask.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCURLSessionDownloadTask.h"
#import "AppDelegate.h"
#import "DFCFileModel.h"
#import "DFCFileHelp.h"
#import "DFCHeader_pch.h"
#import "DFCCoursewareLibraryModel.h"
#import "DFCLocalNotificationCenter.h"
#import "NSURLSession+CorrectedResumeData.h"
#import "DFCCoursewareModel.h"
#import "DFCBoardCareTaker.h"
#import "DFCBoardZipHelp.h"
#import "DFCCloudFileModel.h"

static NSString * const kBackgroundSession   = @"Background Session";
static NSString * const kBackgroundSessionID = @"cn.edu.scnu.DownloadTask.BackgroundSession";

@interface DFCURLSessionDownloadTask () <NSURLSessionDownloadDelegate> {
    NSURLSession *_backgroundSession;
    NSDate *_lastDate; // 上一次时间
    int64_t _byteRead;  // 读取字节数
}

@end

@implementation DFCURLSessionDownloadTask

+ (NSArray *)propertiesNotInTable {
    return @[@"backgroundTask", @"particalData", @"fileModel", @"isExcuting", @"delegate", @"progressBlock", @"downloadBlock", @"leftTimeBlock", @"finishedBlock"];
}

- (instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    
    if (self) {
        _url = url;
    }
    
    return self;
}

- (void)startDownload {
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    
    if (self.particalData) {
        self.backgroundTask = [self.backgroundSession downloadTaskWithCorrectResumeData:self.particalData];
        //self.backgroundTask = [self.backgroundSession downloadTaskWithResumeData:self.particalData];
    } else {
        self.backgroundTask = [self.backgroundSession downloadTaskWithRequest:request];
    }
    
    [self.backgroundTask resume];
    
    // 上一次时间,一秒时间间隔求下载速度
    _lastDate = [NSDate date];
    
    self.isExcuting = YES;
    
    // 代理下载开始
    if ([self.delegate respondsToSelector:@selector(taskStarted:)]) {
        [self.delegate taskStarted:self];
    }
}

- (void)stopDownload {
    self.isExcuting = NO;
    
    __typeof(self)weakSelf = self;
    [self.backgroundTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.particalData = resumeData;
        //self.backgroundTask = nil;
    }];
//    [self.downloadTask suspend];
}

- (void)cancelDownload {
    
    self.isExcuting = NO;
    [self.backgroundTask cancel];
    self.backgroundTask = nil;
    
}

/* 创建一个后台session单例 */
- (NSURLSession *)backgroundSession {
    if (!_backgroundSession) {
        // id = 时间戳加主键
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSString *sessionID = [NSString stringWithFormat:@"%f%@", timeInterval, _fileModel.backgroundSessionId];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sessionID];
        _backgroundSession = [NSURLSession sessionWithConfiguration:config  delegate:self delegateQueue:nil];
        _backgroundSession.sessionDescription = sessionID;
    }
    
    return _backgroundSession;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    // 信任
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    DEBUG_NSLog(@"下载成功");
}

/* 执行下载任务时有数据写入 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten // 每次写入的data字节数
 totalBytesWritten:(int64_t)totalBytesWritten // 当前一共写入的data字节数
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite // 期望收到的所有data字节数
{
    // 下载进度
    double downloadProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
    
//    NSLog(@"%@,%f",self.fileModel.fileName, downloadProgress);
    
    if (self.progressBlock) {
        self.progressBlock(downloadProgress);
    }
    
    // 下载速度
    _byteRead += bytesWritten;
    NSDate *currentDate = [NSDate date];
    if ([currentDate timeIntervalSinceDate:_lastDate] >= 1) {
        //时间差
        NSTimeInterval time = [currentDate timeIntervalSinceDate:_lastDate];
        //计算速度
        long long speed = _byteRead / time;
        //把速度转成KB或M,下载速度回调
        if (self.downloadBlock) {
            self.downloadBlock(downloadProgress, kDFCFileSize(speed));
        }
        if (self.downloadBlock1) {
            self.downloadBlock1(downloadProgress, kDFCFileSize(speed));
        }
        
        // 清零
        _byteRead = 0.0;
        // 记录这次计算的时间
        _lastDate = currentDate;
        
        // 下载剩余时间
        int64_t leftBytesToWrite = totalBytesExpectedToWrite - totalBytesWritten;
        if (speed != 0) {
            NSTimeInterval timeLeft = leftBytesToWrite / speed;
            if (self.leftTimeBlock) {
                self.leftTimeBlock([self timeFormatted:timeLeft]);
            }
        }
    }
}

- (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours == 0) {
        return [NSString stringWithFormat:@"大约%02d分%02d秒", minutes, seconds];
    }
    
    if (minutes == 0) {
        return [NSString stringWithFormat:@"大约%02d秒", seconds];
    }
    
    return [NSString stringWithFormat:@"大约%02d小时%02d分%02d秒",hours, minutes, seconds];
}

/* 从fileOffset位移处恢复下载任务 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    DEBUG_NSLog(@"NSURLSessionDownloadDelegate: Resume download at %lld", fileOffset);
}

/* 完成下载任务，只有下载成功才调用该方法 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    DEBUG_NSLog(@"NSURLSessionDownloadDelegate: Finish downloading");
    
    self.isFinished = YES;
    
    // 3.取消已经完成的下载任务
    self.backgroundTask = nil;
    if ([self.delegate respondsToSelector:@selector(taskFinished:)]) {
        [self.delegate taskFinished:self];
    }
    // 下载完成发送通知刷新页面
    [DFCNotificationCenter postNotificationName:DFC_DOWNLOADTASK_FINISHED_NOTIFICATION object:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
//    coursewareModel.fileSize =

    // m名字
//    NSArray *arr = [_fileModel.fileUrl componentsSeparatedByString:@"."];
//    NSString *type = [arr lastObject];
//    NSString *name = [_fileModel.code stringByAppendingFormat:@".%@", type];
//    
//    NSString *name1 = [[_fileModel.fileUrl componentsSeparatedByString:@"/"] lastObject];
//    
//    NSString *path = [NSString stringWithFormat:@"%@/%@", [DFCFileHelp documentPath], name1];
//    // 若有科目存入科目文件夹
//    if ([DFCUtility isCurrentTeacher]) {
//        if (_fileModel.subjectCode != nil) {
//           // path = [DFCFileHelp pathForCode:DFCUserDefaultManager.teacherCode  subject:_fileModel.subjectCode];
//        }
//    } else {
//        if (_fileModel.subjectCode != nil) {
//            //path = [DFCFileHelp pathForCode:DFCUserDefaultManager.studentCode  subject:_fileModel.subjectCode];
//        }
//    }
//    
    // 更新我的课件本地sqlite
//    _fileModel.finalPath = [path stringByAppendingPathComponent:name];
//    _fileModel.finalPath = path;
//    _fileModel.fileState = kDFCCurrentFileStateComplete;
//    _fileModel.updateDate = [DFCDateHelp currentDate];
//    [_fileModel update];
//    
//    // 更新科目文件夹信息
//    DFCFileModel *fileDir = [[DFCFileModel findByFormat:@"WHERE subjectCode = '%@' AND fileType = 0 and userCode = '%@'", _fileModel.subjectCode, _fileModel.userCode] firstObject];
//    
//    if (fileDir == nil) {
//        // 看科目是否存在,若不存在加一条记录
//        DFCFileModel *newDir = [DFCFileModel new];
//        
//        newDir.fileType = kDFCFileTypeDir;
//        newDir.subjectCode = _fileModel.subjectCode;
//        newDir.userCode = _fileModel.userCode;
//        newDir.code = [NSString stringWithFormat:@"%@%@", _fileModel.userCode, _fileModel.subjectCode];
//        newDir.subjectName = _fileModel.subjectName;
//        newDir.coursewareCount = @"1";
//        newDir.createDate = [DFCDateHelp currentDate];
//        
//        [newDir save];
//    } else {
//        // 看科目是否存在,存在更新
//        NSArray *files = [DFCFileModel findByFormat:@"WHERE subjectCode = '%@' AND fileType = 1 and userCode = '%@'", _fileModel.subjectCode, _fileModel.userCode];
//        
//        fileDir.coursewareCount = [NSString stringWithFormat:@"%li", files.count];
//        [fileDir update];
//    }
//    
//    // 若我的课件在课件库中,更新课件库sqlite
//    DFCCoursewareLibraryModel *model = [DFCCoursewareLibraryModel findByPrimaryKey:_fileModel.code];
//    
//    if (model != nil) {
//        model.finalPath = [path stringByAppendingPathComponent:name];
//        model.fileState = kDFCCurrentFileStateComplete;
//        [model update];
//    }
    
    // 更新数据库
    if (_fileModel.docType != 1) {
        DFCCoursewareModel *coursewareModel = [[DFCCoursewareModel alloc]init];
        coursewareModel.title = _fileModel.fileName;
        coursewareModel.netUrl = _fileModel.fileUrl;
        coursewareModel.coursewareCode = _fileModel.coursewareCode;
        coursewareModel.code = _fileModel.code; // [NSString stringWithFormat:@"%@%@", _fileModel.coursewareCode, [DFCUserDefaultManager getAccounNumber]];
//                                               findByPrimaryKey:_fileModel.coursewareCode];
        coursewareModel.time = [DFCDateHelp currentDate];
        
        
        NSString *finalName = [NSString stringWithFormat:@"%@", [DFCUtility get_uuid]];
        
        coursewareModel.coverImageUrl = [NSString stringWithFormat:@"%@.png", finalName];
        coursewareModel.fileUrl = [NSString stringWithFormat:@"%@.%@", finalName, kDEWFileType];
        coursewareModel.userCode = [DFCUserDefaultManager getAccounNumber];
        
        
//        [[DFCBoardCareTaker sharedCareTaker] addDownloadBoardsForName:finalName];
        
        NSString *finalPath = [[[DFCBoardCareTaker sharedCareTaker] finalBoardPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", finalName, kDEWFileType]];
        NSURL *destinationPath = [NSURL fileURLWithPath:finalPath];
        
        if ([fileManager fileExistsAtPath:[destinationPath path] isDirectory:NULL]) {
            [fileManager removeItemAtURL:destinationPath error:NULL];
        }
        NSError *error = nil;
        if ([fileManager moveItemAtURL:location toURL:destinationPath error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.downloadBlock) {
                    self.downloadBlock(1, @"0k");
                }
                if (self.downloadBlock1) {
                    self.downloadBlock1(1, @"0k");
                }
            });
        }
        // 获取缩略图
        NSString *thumbPath = [[[DFCBoardCareTaker sharedCareTaker] finalBoardPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", finalName]];
        
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        [DFCBoardZipHelp unZipBoard:finalPath destUrl:tmpPath];
        
        //NSString *pathComponent =[NSString stringWithFormat:@"%@/board_0", finalName];
        // add by hmy 下载文件缩略图不对
        NSArray *thumbnailNames = [DFCFileHelp getThumbnailNames:tmpPath];
        NSString *thumbnailName = nil;
        if (thumbnailNames.count >= 1) {
            thumbnailName = [thumbnailNames firstObject];
        }
        NSString *thumbnailStr = [tmpPath stringByAppendingPathComponent:thumbnailName];
        
        [fileManager copyItemAtPath:thumbnailStr toPath:thumbPath error:nil];
        
        long long filesize = [[[NSFileManager defaultManager] attributesOfItemAtPath:finalPath error:nil] fileSize];
        coursewareModel.fileSize = kDFCFileSize(filesize);
        [coursewareModel save];
    } else {
        DFCCloudFileModel *cloudFile = [[DFCCloudFileModel alloc] init];
        cloudFile.userCode = [DFCUserDefaultManager getAccounNumber];
        
        cloudFile.netUrl = _fileModel.fileUrl;
        NSArray *sulist = [_fileModel.fileUrl componentsSeparatedByString:@"."];
        cloudFile.fileUrl = [NSString stringWithFormat:@"%@.%@", [DFCUtility get_uuid], [sulist lastObject]];
        
        NSString *beginPath = [DFCCloudFileModel folderForCloudFile];
        if (![fileManager fileExistsAtPath:beginPath isDirectory:nil]) {
            [fileManager createDirectoryAtPath:beginPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *finalPath = [beginPath stringByAppendingPathComponent:cloudFile.fileUrl];
        NSURL *destinationPath = [NSURL fileURLWithPath:finalPath];
        NSError *error = nil;
        if ([fileManager moveItemAtURL:location toURL:destinationPath error:&error]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isSaveSuccess = [cloudFile save];
                DEBUG_NSLog(@"coursewareName-%@, isSaveSuccess-%d",_fileModel.fileName,isSaveSuccess);
                if (self.downloadBlock) {
                    self.downloadBlock(1, @"0k");
                }
                if (self.downloadBlock1) {
                    self.downloadBlock1(1, @"0k");
                }
                
//                NSString *fileURL = cloudFile.fileUrl;
//                NSString *netURL = cloudFile.netUrl;
                
                if (self.urlBlock) {
                    self.urlBlock(cloudFile.fileUrl,cloudFile.netUrl);
                }
                
//                DEBUG_NSLog(@"111111111111");
                // 本地通知
                [DFCLocalNotificationCenter sendLocalNotification:@"下载成功" subTitle:nil body:_fileModel.fileName type:DFCMessageObjectCountTypeNormal];
                
                AppDelegate *appDelegate = [AppDelegate sharedDelegate];
                if (appDelegate.backgroundURLSessionCompletionHandler) {
                    [DFCLocalNotificationCenter sendLocalNotification:@"下载成功" subTitle:nil body:_fileModel.fileName type:DFCMessageObjectCountTypeNormal];
                    // 执行回调代码块
                    void (^handler)() = appDelegate.backgroundURLSessionCompletionHandler;
                    appDelegate.backgroundURLSessionCompletionHandler = nil;
                    handler();
                }
            });
        }
    }
    
    // 下载完成监听
    if (self.finishedBlock) {
        self.finishedBlock();
    }
}

/* 完成下载任务，无论下载成功还是失败都调用该方法 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    DEBUG_NSLog(@"NSURLSessionDownloadDelegate: Complete task");
    
    self.isEnd = YES;
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(taskFailed:)]) {
            [self.delegate taskFailed:self];
        }
        DEBUG_NSLog(@"下载失败：%@", error);
    }
}

@end

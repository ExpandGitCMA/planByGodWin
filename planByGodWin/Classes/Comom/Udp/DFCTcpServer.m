//
//  DFCTcpServer.m
//  TestTCPServer
//
//  Created by DaFenQi on 2017/6/5.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import "DFCTcpServer.h"
#import "GCDAsyncSocket.h"
#import "DFCStudentWork.h"

@import UIKit;

static NSUInteger const kPort = 32336;

@interface DFCTcpServer () <GCDAsyncSocketDelegate> {
    NSMutableData *_imgData;
    NSUInteger _length;
    NSString *_studentName;
    dispatch_queue_t _golbalQueue;
}

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) NSMutableArray<GCDAsyncSocket *> *clientSockets;
@property (nonatomic, strong) NSMutableDictionary *receivedFilePaths;

@end

@implementation DFCTcpServer

+ (void)startServer {
    [[DFCTcpServer sharedServer] startServer];
}

+ (void)closeServer {
    [[DFCTcpServer sharedServer] closeServer];
}

- (void)closeServer {
    [self.serverSocket disconnect];
}

- (void)startServer {
    NSError *error = nil;
    if (![self.serverSocket acceptOnPort:kPort
                                  error:&error]) {
        DEBUG_NSLog(@"error = %@", error);
        DEBUG_NSLog(@"开放失败");
    } else {
        DEBUG_NSLog(@"开放成功");
    }
}

static DFCTcpServer *_sharedServer;

+ (instancetype)sharedServer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedServer = [[DFCTcpServer alloc] init];
    });
    
    return _sharedServer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _golbalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                       delegateQueue:_golbalQueue];
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_imgData == nil) {
            _imgData = [NSMutableData new];
        }
        
        NSMutableData *mData = [[NSMutableData alloc] initWithData:data];
        
        NSUInteger studentInfoLength = kMaxImageDataLength + kMaxStudentNameLength;
        
        if (data.length > studentInfoLength) {
            uint8_t buf[kMaxStudentNameLength];
            [mData getBytes:(void *)buf range:NSMakeRange(0, kMaxStudentNameLength)];
            NSData *nameData = [NSData dataWithBytes:(void *)buf length:kMaxStudentNameLength];
            NSString *studentName = [[NSString alloc] initWithData:nameData
                                                          encoding:NSUTF8StringEncoding];
            if (studentName) {
                studentName = [studentName stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                studentName = [studentName stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
                _studentName = studentName;
            }
            
            uint8_t lengthBuf[kMaxImageDataLength];
            [mData getBytes:(void *)lengthBuf range:NSMakeRange(kMaxStudentNameLength, kMaxImageDataLength)];
            NSData *lengthData = [NSData dataWithBytes:(void *)lengthBuf length:kMaxImageDataLength];
            NSString *length = [[NSString alloc] initWithData:lengthData
                                                     encoding:NSUTF8StringEncoding];
            NSUInteger tLength = [length integerValue];
            
            if (tLength != 0) {
                _length = tLength;
            }
            if (studentName && tLength != 0) {
                DFCStudentWork *studentWork = [DFCStudentWork new];
                [studentName stringByReplacingOccurrencesOfString:@"/0" withString:@""];
                studentWork.studentName = [studentName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                studentWork.fileSize = tLength;
                studentWork.socket = sock;
                
                uint8_t imgBuf[mData.length - studentInfoLength];
                [mData getBytes:(void *)imgBuf range:NSMakeRange(studentInfoLength, mData.length - studentInfoLength)];
                NSData *imgData = [NSData dataWithBytes:(void *)imgBuf length:mData.length - studentInfoLength];
                
                NSString *imgPath = [self studentWorksImageNewPath:studentName];
                [self.receivedFilePaths setObject:studentWork forKey:imgPath];
                
                [imgData writeToFile:imgPath atomically:YES];
            } else {
                [self insertData:data
                      fromSocket:sock];
            }
        } else {
            [self insertData:data
                  fromSocket:sock];
        }
        
        [sock readDataWithTimeout:-1 tag:0];
    });
}

- (void)insertData:(NSData *)data
        fromSocket:(GCDAsyncSocket *)socket {
    [self.receivedFilePaths.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        DFCStudentWork *studentWork = self.receivedFilePaths[obj];
        if (socket == studentWork.socket) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:key];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
            
            NSData *data = [[NSData alloc] initWithContentsOfFile:key];
            if (data.length == studentWork.fileSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DFCNotificationCenter postNotificationName:DFC_Has_StudentWork_Notification object:nil];
                });
                
                if ([self.delegate respondsToSelector:@selector(tcpServerDidReceiveImage:fromStudent:)]) {
                    [self.delegate tcpServerDidReceiveImage:key
                                                fromStudent:studentWork.studentName];
                }
            }
        }
    }];
}

- (NSMutableArray *)studentWorks:(NSString *)studentName {
    studentName = [NSString stringWithFormat:@"%@%@", [DFCUserDefaultManager lanClassCode], studentName];
    NSMutableArray *studentWorkPaths = [NSMutableArray new];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *students = [fileManager contentsOfDirectoryAtPath:kStudentWorksImageBasePath error:nil];
    for (NSString *dir in students) {
        if ([dir isEqualToString:studentName]) {
            NSString *studentPath = [kStudentWorksImageBasePath stringByAppendingPathComponent:dir];
            NSArray *studentWorks = [fileManager contentsOfDirectoryAtPath:studentPath error:nil];
            for (NSString *work in studentWorks) {
                if ([work hasSuffix:@".jpg"]) {
                    [studentWorkPaths addObject:[studentPath stringByAppendingPathComponent:work]];
                }
            }
        }
    }
    
    [studentWorkPaths sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *path1 = obj1;
        NSString *path2 = obj2;
        
        return [[[path1 lastPathComponent] stringByDeletingPathExtension] integerValue] >
        [[[path2 lastPathComponent] stringByDeletingPathExtension] integerValue];
    }];
    
    return studentWorkPaths;
}

- (NSString *)studentWorksImageNewPath:(NSString *)studentName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:kStudentWorksImageBasePath]) {
        [fileManager createDirectoryAtPath:kStudentWorksImageBasePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    /*
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYYMMDD";
     */
    // [dateFormatter stringFromDate:date]
    NSString *basePath = [kStudentWorksImageBasePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [DFCUserDefaultManager lanClassCode], [studentName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
    if (![fileManager fileExistsAtPath:basePath]) {
        [fileManager createDirectoryAtPath:basePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:basePath
                                                    error:nil];
    
    NSInteger index = -1;
    for (NSString *str in arr) {
        if ([str integerValue] >= index) {
            index = [str integerValue] + 1;
        }
    }
    
    if (index == -1) {
        index = 1;
    }
    
    NSString *imgName = [NSString stringWithFormat:@"%lu.jpg", (unsigned long)index];
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@", basePath, imgName];
    //[basePath stringByAppendingPathComponent:imgName];
    return imgPath;
}

- (NSString *)studentWorksPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:kStudentWorksPath]) {
        [[NSFileManager defaultManager] createFileAtPath:kStudentWorksPath
                                                contents:nil
                                              attributes:nil];
    }
    
    return kStudentWorksPath;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    [self.clientSockets addObject:newSocket];
    
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (NSMutableArray<GCDAsyncSocket *> *)clientSockets {
    if (!_clientSockets) {
        _clientSockets = [NSMutableArray new];
    }
    return _clientSockets;
}

- (NSMutableDictionary *)receivedFilePaths {
    if (!_receivedFilePaths) {
        _receivedFilePaths = [NSMutableDictionary new];
    }
    return _receivedFilePaths;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)err {
    [DFCTcpServer startServer];
}

@end

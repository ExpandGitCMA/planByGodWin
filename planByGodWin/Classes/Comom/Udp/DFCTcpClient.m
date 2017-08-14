//
//  DFCTcpClient.m
//  TestTCPClient
//
//  Created by DaFenQi on 2017/6/5.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import "DFCTcpClient.h"
#import "GCDAsyncSocket.h"
#import <UIKit/UIKit.h>

static NSUInteger const kPort = 32336;

@interface DFCTcpClient () <GCDAsyncSocketDelegate> {
    NSString *_host;
    dispatch_queue_t _golbalQueue;
    MBProgressHUD *_hud;
}

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;

@end

@implementation DFCTcpClient

static DFCTcpClient *_sharedClient;

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DFCTcpClient alloc] init];
    });
    
    return _sharedClient;
}

+ (void)closeClient {
    [[DFCTcpClient sharedClient] disconnectToHost:nil
                                             port:kPort];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _golbalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_golbalQueue];
    }
    return self;
}

- (void)disconnectToHost:(NSString *)host
                    port:(NSUInteger)port {
    _host = nil;
    //_port = -1;
    [_clientSocket disconnect];
}

- (void)connectToHost:(NSString *)host
                 port:(NSUInteger)port {
    if (![DFCUserDefaultManager isUseLANForClass]) return;
    
    if (_host != nil) {
        [_clientSocket disconnect];
    }
    
    _host = host;
//    _port = port;
    NSError *error = nil;
    if (![_clientSocket connectToHost:host
                               onPort:kPort
                          withTimeout:-1
                                error:&error]) {
        DEBUG_NSLog(@"连接失败");
    } else {
        DEBUG_NSLog(@"连接成功");
        self.isConnected = YES;
    }
}

- (void)sendImage:(NSString *)filePath
             name:(NSString *)studentName {
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        _hud.label.text = @"提交中";
    });
    
    NSMutableData *pack = [NSMutableData new];
    
    Byte tempData[kMaxStudentNameLength];
    for (int i = 0; i < kMaxStudentNameLength; i++) {
        tempData[i] = 0;
    }
    NSString *str = [[NSString alloc] initWithBytes:tempData length:kMaxStudentNameLength encoding:NSUTF8StringEncoding];
    NSRange range = NSMakeRange(0, studentName.length);
    studentName = [str stringByReplacingCharactersInRange:range withString:studentName];
    NSData *nameData = [[NSData alloc] initWithData:[studentName dataUsingEncoding:NSUTF8StringEncoding]];
    [pack appendBytes:nameData.bytes length:kMaxStudentNameLength];
    
    DEBUG_NSLog(@"%@", [[NSString alloc] initWithData:pack encoding:NSUTF8StringEncoding]);
    
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:filePath];
    NSData *imgData = UIImageJPEGRepresentation(img, 1);
    
    NSString *lengthStr = [NSString stringWithFormat:@"%@", @(imgData.length)];
    NSData *lengthData = [[NSData alloc] initWithData:[lengthStr dataUsingEncoding:NSUTF8StringEncoding]];
    [pack appendBytes:lengthData.bytes length:kMaxImageDataLength];

    [pack appendData:imgData];
    
    [_clientSocket writeData:pack
                 withTimeout:-1
                         tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    DEBUG_NSLog(@"连接成功");
    [self.clientSocket readDataWithTimeout:-1 tag:1];
    self.isConnected = YES;
}

- (void)socket:(GCDAsyncSocket *)sock
   didReadData:(NSData *)data
       withTag:(long)tag{
    [self.clientSocket readDataWithTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DEBUG_NSLog(@"发送成功");
    dispatch_async(dispatch_get_main_queue(), ^{
        [DFCProgressHUD showSuccessWithStatus:@"发送成功, 请间隔3秒后继续发送"];
        [_hud removeFromSuperview];
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)err {
    if (_host) {
        [self connectToHost:_host
                       port:kPort];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud removeFromSuperview];
    });
    self.isConnected = NO;
}

@end

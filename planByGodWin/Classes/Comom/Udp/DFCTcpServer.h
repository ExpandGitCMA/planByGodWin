//
//  DFCTcpServer.h
//  TestTCPServer
//
//  Created by DaFenQi on 2017/6/5.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DFCTcpServerDelegate <NSObject>

- (void)tcpServerDidReceiveImage:(NSString *)filePath
                     fromStudent:(NSString *)studentName;

@end

@interface DFCTcpServer : NSObject

+ (void)startServer;
+ (void)closeServer;

+ (instancetype)sharedServer;

- (NSMutableArray *)studentWorks:(NSString *)studentName;

@property (nonatomic, assign) id<DFCTcpServerDelegate> delegate;

@end

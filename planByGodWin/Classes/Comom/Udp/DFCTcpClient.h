//
//  DFCTcpClient.h
//  TestTCPClient
//
//  Created by DaFenQi on 2017/6/5.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface DFCTcpClient : NSObject

+ (instancetype)sharedClient;
+ (void)closeClient;

- (void)connectToHost:(NSString *)host
                 port:(NSUInteger)port;
- (void)disconnectToHost:(NSString *)host
                    port:(NSUInteger)port;
- (void)sendImage:(NSString *)filePath
             name:(NSString *)studentName;

@property (nonatomic, assign) BOOL isConnected;

@end

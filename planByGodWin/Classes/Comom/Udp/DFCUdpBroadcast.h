//
//  DFCUdpBroadcast.h
//  TestUDPBroadcast
//
//  Created by DaFenQi on 2017/5/19.
//  Copyright © 2017年 DaFenQi. All rights reserved.
//
// 数据包+Mantle

#import <Foundation/Foundation.h>

@protocol DFCUdpBroadcastDelegate <NSObject>

- (void)udpSocketDidReceiveMessage:(NSDictionary *)message;

@end

@interface DFCUdpBroadcast : NSObject

+ (void)broadcast;

+ (instancetype)sharedBroadcast;

@property (nonatomic, assign) id<DFCUdpBroadcastDelegate> delegate;

- (void)sendMessage:(NSDictionary *)message;
- (void)sendData:(NSData *)data;

- (void)sendToTeacherMessage:(NSDictionary *)message;
- (void)sendToTeacherData:(NSData *)data;

- (void)connectToTeacher:(NSDictionary *)message;
- (void)closeUdp;

@end

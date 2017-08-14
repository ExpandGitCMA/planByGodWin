//
//  ERSocket.h
//  AudioTracker
//
//  Created by shine on 16/8/17.
//  Copyright © 2016年 -. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ERSocket, ERBackPacketBody;
@protocol ERSocketDelegate <NSObject>

//暂时不用实现
@optional
- (void)socketDidConnect:(ERSocket *)socket;
- (void)socketDidDisconnect:(ERSocket *)socket;
- (void)socketDidSendCmd:(ERSocket *)socket cmd:(NSString *)seat status:(BOOL)status;
- (void)socketDidGetSeatsLayout:(ERSocket *)socket seatsLayout:(ERBackPacketBody *)seatsLayout;
@end



@interface ERSocket : NSObject

@property (nonatomic, copy) NSString *Host;
@property (nonatomic, copy) NSString *Port;
@property (nonatomic, weak) id<ERSocketDelegate> delegate;
@property (nonatomic, assign) BOOL connected;
+ (instancetype)sharedManager;

- (void)connect;
- (void)disconnect;
- (void)sendAudioData:(NSData *)audioData;
- (void)sendSeatLocaation:(NSString *)seat;
- (void)beginOrEndClass:(BOOL)a info:(NSString *)info  coursewareCode:(NSString*)coursewareCode coursewareName:(NSString*)coursewareName;
- (void)switchScreen:(NSInteger)type;
- (void)requestTakePhoto:(NSInteger)scene;
- (void)requestCommunication:(NSInteger)Scenetype;
- (void)requestStream:(NSInteger)SceneStreamtype;
- (void)requestStopStream:(NSInteger)SceneStoptype;
- (void)requestAudioStreamProtocol;
- (void)requestSeatList;
- (void)requestSendDeviceSeat:(NSString*)jison;
- (void)requestSearchDevice;
- (void)requestUpdateDeviceIP:(NSString*)jison;
- (void)requestDeviceStatuspush;

@end

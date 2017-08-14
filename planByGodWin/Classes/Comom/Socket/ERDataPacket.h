//
//  ERDataPacket.h
//  AudioTracker
//
//  Created by shine on 16/8/16.
//  Copyright © 2016年 -. All rights reserved.
//

#import <Foundation/Foundation.h>

extern UInt32 HeadSign;
extern UInt32 BodySign;
extern UInt16 HeadStatus;
extern UInt16 CmdDiffer;



typedef NS_ENUM(UInt16, ERCmdType) {
    ERCmdTypeAudioData   = 0x0001,
    ERCmdTypeWantLocate  = 0x0101,
    ERCmdTypeEndLocate   = 0x0102,
    ERCmdTypeSeatsLayout = 0x0103,
    ERCmdTypeBeginClass  = 0x0104,
    ERCmdTypeEndClass    = 0x0105 ,// 下课了
    ERCmdTypeSceneSwitch = 0x0106,
    ERCmdTypeTakePhoto    = 0x0107,
    ERCmdTypeMasterVideo    = 0x0108,//（控制协议之建立播放通道）
    ERCmdTypeRequestStream    = 0x0109,//（控制协议之请求码流）
    ERCmdTypeStopStream    = 0x0112,//（控制协议之停止播放）
    ERCmdTypeAudioStreamProtocol  = 0x0114,//音频视流传输协议
    ERCmdTypeRequestSeatList  = 0x0116,//请求获取机位配置列表
    ERCmdTypeSendDeviceSeat  =0x0117,//发送设备配置修改参数
    ERCmdTypeSearchDevice = 0x0118,//请求搜索设备
    ERCmdTypeUpdateDeviceIP =0x0119,//请求修改设备IP与机位绑定
    ERCmdTypeDeviceStatuspush =0x0121//设备状态列表推送
    //0x0121
};

typedef NS_ENUM(UInt8, HeadLengthType) {
    HeadLengthTypeNoExtend = 20,
    HeadLengthTypeAudio    = 28
};

typedef NS_ENUM(int8_t, ERDataType) {
    ERDataTypeNo     = 0,
    ERDataTypeStream = 1,
    ERDataTypeString = 2,
    ERDataTypeJson   = 3
};

typedef NS_ENUM(UInt16, AudioEncodeType) {
    AudioEncodeTypeG711U = 1
};

@class ERBackPacketHead;
@class ERBackPacketBody;
@interface ERDataPacket : NSObject

@property (nonatomic, assign) UInt16 sessionId;
@property (nonatomic, copy) NSString *lastSeat;
+ (instancetype)manager;
-(NSString*)classBeginStatus;
-(NSData *)generateWantLocateDataPacketWithSeatString:(NSString *)seat;
-(NSData *)generateEndLocateDataPacket;
-(NSData *)generateAudioDataPacketWithData:(NSData *)audioData;
-(NSData *)generateBeginClassDataPacket:(NSString *)info coursewareCode:(NSString *)coursewareCode coursewareName:(NSString *)coursewareName;
-(NSData *)generateEndClassDataPacket;
-(NSData *)generateBackDataPacketWithCmd:(ERCmdType)cmd;
-(NSData *)generateSceneSwitchDataPacket:(NSInteger)type;
-(NSData *)generateRequestTakePhotoDataPacket:(NSInteger)scene;
//请求主录音视频（控制协议之建立播放通道）
-(NSData *)generateRequestCommunication:(NSInteger)Scenetype;
//请求主录音视频（控制协议之请求码流）
-(NSData *)generateRequestStream:(NSInteger)SceneStreamtype;
//请求主录音视频（控制协议之停止播放）
-(NSData *)generateStopStream:(NSInteger)SceneStoptype;

-(NSData *)generateRequestAudioStreamProtocol;
-(NSData *)generateRequestSeatList;
-(NSData *)generateRequestSendDeviceSeat:(NSString*)jison;
-(NSData *)generateRequestSearchDevice;
-(NSData *)generateRequestUpdateDeviceIP:(NSString*)jison;
-(NSData *)generateRequestDeviceStatuspush;
-(NSData *)didReadDataPacket:(NSData *)data;
- (BOOL)analyzeBackData:(NSData *)backData;
- (ERBackPacketHead *)analyzeHeadData:(NSData *)data;
//- (ERBackPacketBody *)analyzeSeatsLayoutData:(NSData *)data;
- (void)analyzeErServerData:(NSData *)data;
- (void)configureAudioSampleRate:(NSUInteger)sampleRate bits:(NSUInteger)bits channels:(NSUInteger)channels;

@end


@interface ERBackPacketHead : NSObject

@property (nonatomic, assign) ERCmdType cmd;
@property (nonatomic, assign) UInt16 status;
@property (nonatomic, assign) ERDataType dataType;

@property (nonatomic, assign) BOOL requestStatus;

@end

@interface ERBackPacketBody : NSObject

@property (nonatomic, copy) NSString *seatMode;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSArray<NSString *> *seats;

@end



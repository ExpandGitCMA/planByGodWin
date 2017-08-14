//
//  ERSocket.m
//  AudioTracker
//
//  Created by shine on 16/8/17.
//  Copyright © 2016年 -. All rights reserved.
//

#import "ERSocket.h"
#import "ERDataPacket.h"
#import "GCDAsyncSocket.h"
#import "CRecorder.h"
#import "AppDelegate.h"
#import "NSString+NSStringSizeString.h"
#define CmdSeat(numStr) [NSString stringWithFormat:@"Seat<%@>", numStr]

static NSString *Host = @"192.168.1.2";
static NSString *Port = @"9666";

typedef NS_ENUM(long, SocketWriteType) {
    SocketWriteTypeAudio    = 0,
    SocketWriteTypeLocation = 1
};

typedef NS_ENUM(long, SocketReadType) {
    SocketReadTypeSeatsLayout = 0,
    SocketReadTypeCmd         = 1
};

typedef NS_ENUM(long, SocketReadProcessType) {
    SocketReadProcessTypeHeadSign   = 0,
    SocketReadProcessTypeBodySigh   = 1,
    SocketReadProcessTypeHeadlength = 2,
    SocketReadProcessTypeBodylenght = 3,
    SocketReadProcessTypeHead       = 4,
    SocketReadProcessTypeBody       = 5
};

@interface ERSocket ()<GCDAsyncSocketDelegate,CRecDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) CRecorder *audioRecorder;
@end

@implementation ERSocket

static ERSocket *manager = nil;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
        
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [ERSocket sharedManager];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [ERSocket sharedManager];
}

- (instancetype)init
{
    return [self initWithHost:Host port:Port delegate:nil];
}

- (instancetype)initWithHost:(NSString *)host port:(NSString *)port delegate:(id<ERSocketDelegate>)delegate
{
    if (self = [super init]) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("singleQueue", DISPATCH_QUEUE_SERIAL)];
        _Host = host;
        _Port = port;
        _delegate = delegate;
   
        //设置语音数据参数，采样率，位宽，通道数
        [[ERDataPacket manager] configureAudioSampleRate:16000 bits:16 channels:1];
    }
    return self;
}

- (void)connect
{
    if ([DFCUtility isCurrentTeacher]) {
        self.Host = [DFCUserDefaultManager getRecordPlayIP];
    } else {
        
    }
    NSError *error = nil;
    [self.socket connectToHost:self.Host onPort:[self.Port intValue] withTimeout:3 error:&error];
}

- (void)disconnect
{
    //停止语音采集
    if (self.audioRecorder) {
        [self.audioRecorder stop];
         self.audioRecorder = nil;
    }
    [self.socket disconnect];
}

- (void)sendAudioData:(NSData *)audioData{
    NSData *sendData = [[ERDataPacket manager] generateAudioDataPacketWithData:audioData];
    [self.socket writeData:sendData withTimeout:-1 tag:SocketWriteTypeAudio];
}

- (void)sendSeatLocaation:(NSString *)seat
{
    NSData *sendData = nil;
    if (seat) {
        sendData = [[ERDataPacket manager] generateWantLocateDataPacketWithSeatString:seat];
    }else{
        sendData = [[ERDataPacket manager] generateEndLocateDataPacket];
    }
    [self.socket writeData:sendData withTimeout:-1 tag:SocketWriteTypeLocation];
}

- (void)beginOrEndClass:(BOOL)a info:(NSString *)info coursewareCode:(NSString *)coursewareCode coursewareName:(NSString *)coursewareName
{
    NSData *sendData = nil;
    if (a) {
        sendData = [[ERDataPacket manager] generateBeginClassDataPacket:info coursewareCode:coursewareCode coursewareName:coursewareName];
    }else{
         sendData = [[ERDataPacket manager] generateEndClassDataPacket];
    }
    [self.socket writeData:sendData withTimeout:-1 tag:SocketWriteTypeAudio];
}


-(void)endClassStatus{
     dispatch_after(dispatch_time(
                                 DISPATCH_TIME_NOW,
                                 (int64_t)(10ull * NSEC_PER_SEC)),
                    dispatch_get_main_queue(),^{
                        
        NSString*status =  [[ERDataPacket manager] classBeginStatus];
                        
            if ([status isEqualToString:@"1"]) {
                        dispatch_after_f(dispatch_time
                                (DISPATCH_TIME_NOW, 20ull *NSEC_PER_SEC),
                                  dispatch_get_main_queue(), NULL,
                                  againEndClass);
                       DEBUG_NSLog(@"再次发送下课==%@",status);
                 }else{
                     DEBUG_NSLog(@"下课成功");
            }
    });
}


void againEndClass(){
    NSString*status =  [[ERDataPacket manager] classBeginStatus];
    if ([status isEqualToString:@"1"]) {
        [manager beginOrEndClass:NO info:nil coursewareCode:nil coursewareName:nil];
    }
}

-(void)switchScreen:(NSInteger)type{
    NSData *sendData = [[ERDataPacket manager] generateSceneSwitchDataPacket:type];
    [self.socket writeData:sendData withTimeout:-1 tag:SocketWriteTypeAudio];
}

//录播服务器后续命令操作
-(void)requestTakePhoto:(NSInteger)scene{
    NSData *sendData = [[ERDataPacket manager]generateRequestTakePhotoDataPacket:scene];
      [self.socket writeData:sendData withTimeout:-1 tag:SocketWriteTypeAudio];
}

- (void)requestCommunication:(NSInteger)Scenetype{

}

- (void)requestStream:(NSInteger)SceneStreamtype{

}

- (void)requestStopStream:(NSInteger)SceneStoptype{

}
- (void)requestAudioStreamProtocol{

}
- (void)requestSeatList{

}
- (void)requestSendDeviceSeat:(NSString*)jison{

}
- (void)requestSearchDevice{

}
- (void)requestUpdateDeviceIP:(NSString*)jison{

}
- (void)requestDeviceStatuspush{

}

#pragma mark - GCDSocketDelegateMethod
#pragma mark 连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self canRecord];
    
//      [[AppDelegate sharedDelegate]openSocketTask];
    self.connected = YES;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidConnect:)]) {
//        [self.delegate socketDidConnect:self];
//    }
    
    //开始语音采集
    if (self.audioRecorder == nil) {
        self.audioRecorder = [[CRecorder alloc] initWithSampleRate:self withSampleRate:16000 atChannels:1];
    }
    [self.audioRecorder start];
    
    NSNumber *boolNumber = [[NSNumber alloc] initWithBool:YES];
    [DFCNotificationCenter postNotificationName:DFC_RP_CONNECTION_STATUS_NOTIFICATION object:boolNumber];
    
    UInt32 headSign = HeadSign;
    NSData *headSighData = [[NSData alloc] initWithBytes:&headSign length:sizeof(UInt32)];
    [self.socket readDataToData:headSighData withTimeout:-1 tag:SocketReadProcessTypeHeadSign];
}


#pragma mark - CRecDelegate
- (void)OnAudioData:(AudioQueueBufferRef)buffer
{
    NSData *audioData = [[NSData alloc] initWithBytes:buffer->mAudioData length:buffer->mAudioDataByteSize];

    if (buffer->mAudioDataByteSize==0) {
//        DEBUG_NSLog(@" 掉线啦");
    }
    //捕获音频异常
    @try {
      [self sendAudioData:audioData];
    } @catch (NSException *exception) {
//        DEBUG_NSLog(@"name:%@",exception.name);
//        DEBUG_NSLog( @"Reason: %@", exception.reason );
    } @finally {
//        DEBUG_NSLog( @"In finally block");
    }
}


#pragma mark 断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    NSNumber *boolNumber = [[NSNumber alloc] initWithBool:NO];
    [DFCNotificationCenter postNotificationName:DFC_RP_CONNECTION_STATUS_NOTIFICATION object:boolNumber];
    if (err) {
        [self connect];
        //发送上课命令
        return;
    }
    self.connected = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidDisconnect:)]) {
        [self.delegate socketDidDisconnect:self];
    }
    
}


#pragma mark - 暂时无用的代码 录播回调信息
#pragma mark 发送数据
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//     DEBUG_NSLog(@"%s",__func__);
}

#pragma mark 读取数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [self socketReadProcessData:data tag:tag];
    // 全部NSData  [sock readDataWithTimeout:-1 tag:0];
    // 四字节NSData  [sock readDataToLength:data.length withTimeout:-1 tag:0];
}


//用来处理录播服务器发的信息
- (void)socketReadProcessData:(NSData *)data tag:(long)tag
{
    switch (tag) {
        case SocketReadProcessTypeHeadSign:
        {
            [self.socket readDataToLength:sizeof(UInt8) withTimeout:-1 tag:SocketReadProcessTypeHeadlength];
            break;
        }
            
        case SocketReadProcessTypeHeadlength:
        {
            UInt8 buf = 0;
            [data getBytes:&buf length:sizeof(UInt8)];
            NSUInteger length = buf - 1;
            [self.socket readDataToLength:length withTimeout:-1 tag:SocketReadProcessTypeHead];
            break;
        }
            
        case SocketReadProcessTypeHead:
        {
            ERBackPacketHead *head = [[ERDataPacket manager] analyzeHeadData:data];
            if (head.requestStatus) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidSendCmd:cmd:status:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate socketDidSendCmd:self cmd:[ERDataPacket manager].lastSeat status:YES];
                    });
                }
            }
            if (head.dataType == ERDataTypeNo) {
                UInt32 headSign = HeadSign;
                NSData *headSighData = [[NSData alloc] initWithBytes:&headSign length:sizeof(UInt32)];
                [self.socket readDataToData:headSighData withTimeout:-1 tag:SocketReadProcessTypeHeadSign];                
                
            }else{
                NSData *backDataPacket = [[ERDataPacket manager] generateBackDataPacketWithCmd:head.cmd];
                [self.socket writeData:backDataPacket withTimeout:-1 tag:0];
                
                UInt32 bodySign = BodySign;
                NSData *bodySignData = [[NSData alloc] initWithBytes:&bodySign length:sizeof(UInt32)];
                [self.socket readDataToData:bodySignData withTimeout:-1 tag:SocketReadProcessTypeBodySigh];
            }
            break;
        }
            
        case SocketReadProcessTypeBodySigh:
        {
            [self.socket readDataToLength:sizeof(UInt32) withTimeout:-1 tag:SocketReadProcessTypeBodylenght];
            break;
        }
            
        case SocketReadProcessTypeBodylenght:
        {
            UInt32 buf = 0;
            [data getBytes:&buf length:sizeof(UInt32)];
            NSUInteger lenght = buf - sizeof(UInt32);
            [self.socket readDataToLength:lenght withTimeout:-1 tag:SocketReadProcessTypeBody];
            break;
        }
            
        case SocketReadProcessTypeBody:
        {
//            ERBackPacketBody *seatsLayout = [[ERDataPacket manager] analyzeSeatsLayoutData:data];
//            if (self.delegate && [self.delegate respondsToSelector:@selector(socketDidGetSeatsLayout:seatsLayout:)]) {
//                [self.delegate socketDidGetSeatsLayout:self seatsLayout:seatsLayout];
//            }
            [[ERDataPacket manager] analyzeErServerData:data];
            UInt32 headSign = HeadSign;
            NSData *headSighData = [[NSData alloc] initWithBytes:&headSign length:sizeof(UInt32)];
            [self.socket readDataToData:headSighData withTimeout:-1 tag:SocketReadProcessTypeHeadSign];
            break;
        }
        default:
            break;
    }
}


-(void)canRecord{
       __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                               delegate:nil
                                      cancelButtonTitle:@"关闭"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }

}


- (void)dealloc {
      DEBUG_NSLog(@"%@:----释放了",NSStringFromSelector(_cmd));
}
@end

//
//  ERDataPacket.m
//  AudioTracker
//
//  Created by shine on 16/8/16.
//  Copyright © 2016年 -. All rights reserved.
//

#import "ERDataPacket.h"

#define HeadVersion 0x11
UInt32 HeadSign = 0x6c6c8d8d;
UInt32 BodySign = 0x00dd5500;
UInt16 HeadStatus = 0;
UInt16 CmdDiffer = 32768;



static UInt8 CmdLocation = 1;
static UInt8 StatusLocation = 3;
static UInt8 DataTypeLocation = 18;
static UInt8 NumberLocation = 7;

@interface ERDataPacket ()
{
    UInt32 _wantLocateNumber;
    UInt32 _endLocateNumber;
    UInt32 _audioDataNumber;
    
    UInt16 _lastCmd;
    
    NSData *_audioHeadExtendData;
    NSString *_coursewareCode;
    NSString *_classBeginSign;
}

@end

static ERDataPacket *_instance = nil;
@implementation ERDataPacket

+ (instancetype)manager
{
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _wantLocateNumber = 0;
        _endLocateNumber = 0;
        _audioDataNumber = 0;
        _coursewareCode = nil;
        _audioHeadExtendData = nil;
    }
    return self;
}

#pragma mark - 录播命令数据包组包函数组
- (NSData *)generateWantLocateDataPacketWithSeatString:(NSString *)seat
{
//     NSInteger no = [seat intValue];
    NSInteger no = [self setValueLcationKey:seat] +1;
//    NSString *bodyString1 = [[NSString alloc] initWithFormat:@"seat=Seat<%ld>\0", no];
    NSString *bodyString = [[NSString alloc] initWithFormat:@"seat=%ld\0", no];
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *bodyData = [bodyString dataUsingEncoding:encode];
    self.lastSeat = seat;
    
    return [self generateDataPacketWithCmdType:ERCmdTypeWantLocate bodyData:bodyData headExtendData:nil];
}

#pragma mark-座位表排序
static NSInteger line = 8;//列数
static NSInteger row = 7;//行数
static NSInteger zero = 0;
-(NSInteger)setValueLcationKey:(NSString *)seat{
    NSInteger  value =  (row*line -[seat intValue]-1);
    NSInteger  key = zero ;
    if (value<=row) {
        key = zero+row -value;
    }else if (value<=15){
        key = line+15 -value;
    }else if (value<=23){
        key = 2*line+23 -value;
    }else if (value<=31){
        key = 3*line+31 -value;
    }else if (value<=39){
        key =  4*line+39 -value;
    }else if (value<=47){
        key =  5*line+47 -value;
    }else if (value<=55){
        key =  6*line+55 -value;
    }
    DEBUG_NSLog(@"key==%ld",key);
    return key;
}

- (NSData *)generateEndLocateDataPacket
{
    return [self generateDataPacketWithCmdType:ERCmdTypeEndLocate bodyData:nil headExtendData:nil];
}

- (NSData *)generateAudioDataPacketWithData:(NSData *)audioData;
{
    return [self generateDataPacketWithCmdType:ERCmdTypeAudioData bodyData:audioData headExtendData:_audioHeadExtendData];
}

#pragma mark-开始上课
- (NSData *)generateBeginClassDataPacket:(NSString *)info coursewareCode:(NSString *)coursewareCode coursewareName:(NSString *)coursewareName
{
    NSString *grade = [info substringWithRange:NSMakeRange(4, 2)];
    NSString *class = [info substringWithRange:NSMakeRange(6, 2)];
    NSString *courseInfo = [NSString stringWithFormat:@"coursename=%@&grade=%@&class=%@&tearcher=%@&am=true&section=1&courseduration=45&coursecode=%@", coursewareName,grade, class, [DFCUserDefaultManager getTeacherInfoCache][@"teacherInfo"][@"name"],coursewareCode];

    _coursewareCode = coursewareCode;
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *bodyData = [courseInfo dataUsingEncoding:encode];
    return [self generateDataPacketWithCmdType:ERCmdTypeBeginClass bodyData:bodyData headExtendData:nil];
}

#pragma mark-录播是否在录制状态
- (void)analyzeErServerData:(NSData *)data{
    
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *dataString = [[NSString alloc] initWithData:data encoding:encode];
        
    NSArray *stringArray = [dataString componentsSeparatedByString:@"&"];
    NSString *classBeginSign = @"ClassBegin=";
    NSString *classBegin = nil;

//    NSString *controlModeSign = @"ControlMode=";
//    NSString *courseBeginTimeSign = @"CourseBeginTime=";
//    NSString *courseDurationSign = @"CourseDuration=";
//    NSString *mainCameraSign = @"MainCamera=";
//    NSString *manualSwitchSign = @"ManualSwitch=";
//    NSString *controlMode = nil;
//    NSString *courseBeginTime = nil;
//    NSString *courseDuration = nil;
//    NSString *mainCamera = nil;
//    NSString *manualSwitch = nil;
    
    for (NSString *str in stringArray) {
        if ([str hasPrefix:classBeginSign]) {
            classBegin = [str substringFromIndex:classBeginSign.length];
            _classBeginSign =  [str substringFromIndex:classBeginSign.length];
            DEBUG_NSLog(@"classBeginSign==%@",_classBeginSign);
            if ([classBegin isEqualToString:@"0"]&&!([[_coursewareCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)) {
                DEBUG_NSLog(@"开始录制第二集");
                NSNumber *boolNumber = [[NSNumber alloc] initWithBool:YES];
                [DFCNotificationCenter postNotificationName:DFC_RP_CONNECTION_STATUS_NOTIFICATION object:boolNumber];
            }
            
        }
//        if ([str hasPrefix:controlModeSign]) {
//            controlMode = [str substringFromIndex:controlModeSign.length];
//        }
//        if ([str hasPrefix:courseBeginTimeSign]) {
//            courseBeginTime = [str substringFromIndex:courseBeginTimeSign.length];
//        }
//        if ([str hasPrefix:courseDurationSign]) {
//            courseDuration = [str substringFromIndex:courseDurationSign.length];
//        }
//        if ([str hasPrefix:mainCameraSign]) {
//            mainCamera = [str substringFromIndex:mainCameraSign.length];
//        }
//        if ([str hasPrefix:manualSwitchSign]) {
//            manualSwitch = [str substringFromIndex:manualSwitchSign.length];
//        }
    }
    
}

-(NSString*)classBeginStatus{
    return _classBeginSign;
}

#pragma mark-下课操作命令数据
- (NSData *)generateEndClassDataPacket
{
    NSString *courseInfo = @"coursecode=99\0";
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *bodyData = [courseInfo dataUsingEncoding:encode];
    _coursewareCode = nil;
    return [self generateDataPacketWithCmdType:ERCmdTypeEndClass bodyData:bodyData headExtendData:nil];
}

#pragma mark-切换场景操作命令数据
-(NSData *)generateSceneSwitchDataPacket:(NSInteger)type{
    NSString *courseInfo;
    switch (type) {
        case 0:{//讲台全景
            courseInfo = @"1";
        }
            break;
        case 1:{//教师跟踪
            courseInfo = @"2";
        }
            break;
        case 2:{//板书特写
            courseInfo = @"3";
        }
            break;
        case 3:{//学生全景
            courseInfo = @"4";
        }
            break;
        case 4:{//学生跟踪
            courseInfo = @"5";
        }
            break;
        case 5:{//教学机屏幕 投影屏幕
            courseInfo = @"6";
        }
            break;
        case 6:{
            //恢复录播自动切换
             courseInfo = @"99";
        }break;
        default:
            break;
    }
    NSString *bodyString = [[NSString alloc] initWithFormat:@"scene=%@\0", courseInfo];
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *bodyData = [bodyString dataUsingEncoding:encode];
    DEBUG_NSLog(@"bodyString===%@",bodyString);
    return [self generateDataPacketWithCmdType:ERCmdTypeSceneSwitch bodyData:bodyData headExtendData:nil];
}

#pragma mark-请求抓图
-(NSData *)generateRequestTakePhotoDataPacket:(NSInteger)scene{
    NSString *courseInfo;
    switch (scene) {
        case 0:{//教师跟踪
            courseInfo = @"0";
        }
            break;
        case 1:{//学生特写
            courseInfo = @"1";
        }
            break;
        case 2:{//板书
            courseInfo = @"2";
        }
            break;
        case 3:{//教学课件
            courseInfo = @"3";
        }
            break;
            default:
            break;
    }
    
    NSString *bodyString = [[NSString alloc] initWithFormat:@"scene=%@\0", courseInfo];
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *bodyData = [bodyString dataUsingEncoding:encode];
    return [self generateDataPacketWithCmdType:ERCmdTypeTakePhoto bodyData:bodyData headExtendData:nil];
}

#pragma mark-请求主录音视频
-(NSData *)generateRequestCommunication:(NSInteger)Scenetype{
    NSString *courseInfo;
    switch (Scenetype) {
        case 0:{//教师跟踪
            courseInfo = @"0";
        }
            break;
        case 1:{//学生特写
            courseInfo = @"1";
        }
            break;
        case 2:{//板书
            courseInfo = @"2";
        }
            break;
        case 3:{//教学课件
            courseInfo = @"3";
        }
            break;
        default:
            break;
    }
    
    NSString *bodyString = [[NSString alloc] initWithFormat:@"scene=%@\0", courseInfo];
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *bodyData = [bodyString dataUsingEncoding:encode];
    return [self generateDataPacketWithCmdType:ERCmdTypeMasterVideo bodyData:bodyData headExtendData:nil];
}

-(NSData *)generateRequestStream:(NSInteger)SceneStreamtype{
       return nil;
}
//请求主录音视频（控制协议之停止播放）
-(NSData *)generateStopStream:(NSInteger)SceneStoptype{
    return nil;
}

-(NSData *)generateRequestAudioStreamProtocol{
    return nil;
}
-(NSData *)generateRequestSeatList{
    return nil;
}
-(NSData *)generateRequestSendDeviceSeat:(NSString*)jison{
    return nil;
}
-(NSData *)generateRequestSearchDevice{
    return nil;
}
-(NSData *)generateRequestUpdateDeviceIP:(NSString*)jison{

    return nil;
}
-(NSData *)generateRequestDeviceStatuspush{
    return nil;
}

-(NSData *)didReadDataPacket:(NSData*)data {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
   NSString*   ret = [[NSString alloc]initWithData:data encoding:enc];
    DEBUG_NSLog(@"result===%@",ret);
    return nil;
}

-(NSString *)transToStr:(NSData *)data{
    NSString *str=[NSString stringWithFormat:@"%@",data];
    return str;
}

- (NSString *)data2Hex:(NSData *)data {
    if (!data) {
        return nil;
    }
    Byte *bytes = (Byte *)[data bytes];
    NSMutableString *str = [NSMutableString stringWithCapacity:data.length * 2];
    for (int i=0; i < data.length; i++){
        [str appendFormat:@"%0x", bytes[i]];
    }
    return str;
}

/**
 配置语音数据包包头语音参数
 @param sampleRate 采样率
 @param bits 位宽
 @param channels 通道数
 */
- (void)configureAudioSampleRate:(NSUInteger)sampleRate bits:(NSUInteger)bits channels:(NSUInteger)channels
{
    UInt32 s = (UInt32)sampleRate;
    UInt8 b = (UInt8)bits;
    UInt8 c = (UInt8)channels;
    AudioEncodeType encodeType = AudioEncodeTypeG711U;
    
    NSMutableData *headExtendData = [[NSMutableData alloc] initWithBytes:&s length:sizeof(UInt32)];
    [headExtendData appendBytes:&b length:sizeof(UInt8)];
    [headExtendData appendBytes:&c length:sizeof(UInt8)];
    [headExtendData appendBytes:&encodeType length:sizeof(AudioEncodeType)];
    
    _audioHeadExtendData = [headExtendData copy];
}


/**
 产生数据包最终调用函数
 @param cmdType 命令字类型
 @param bodyData 包体数据
 @param headExtendData 包头扩展数据（例如：语音数据参数采样率等。。。）
 @return 用于发送的data数据包
 */
- (NSData *)generateDataPacketWithCmdType:(ERCmdType)cmdType bodyData:(NSData *)bodyData headExtendData:(NSData *)headExtendData
{
    
    NSData *head = [self generateHeadWithCmdType:cmdType headExtendData:headExtendData];
    NSData *body = [self generateBodyWithBodyData:bodyData];
    
    NSMutableData *data = [[NSMutableData alloc] initWithData:head];
    [data appendData:body];
    
    return [data copy];
//    UInt32 headSign = HeadSign;
//    HeadLengthType headLength = [self generateHeadlength:cmdType];
//    UInt8 headVersion = HeadVersion;
//    ERCmdType cmd = cmdType;
//    UInt16 headStatus = HeadStatus;
//    UInt16 sessionId = (UInt16)self.sessionId;
//    UInt32 packetNumber = [self generatePacketNumber:cmdType];
//    NSData *timeData = [self generateTimeStampData];
//    ERDataType dataType = [self generateDataType:cmdType];
//    
//    UInt32 bodySign = BodySign;
//    NSString *bodyString = [[NSString alloc] initWithFormat:@"seat=<%@>", seat];
//    NSData *bodyData = [bodyString dataUsingEncoding:NSASCIIStringEncoding];
//    UInt32 bodyLength = (UInt32)[bodyData length];
//    
//    NSMutableData *data = [[NSMutableData alloc] initWithBytes:&headSign length:sizeof(UInt32)];
//    [data appendBytes:&headLength length:sizeof(HeadLengthType)];
//    [data appendBytes:&headVersion length:sizeof(UInt8)];
//    [data appendBytes:&cmd length:sizeof(ERCmdType)];
//    [data appendBytes:&headStatus length:sizeof(UInt16)];
//    [data appendBytes:&sessionId length:sizeof(UInt16)];
//    [data appendBytes:&packetNumber length:sizeof(UInt32)];
//    [data appendData:timeData];
//    [data appendBytes:&dataType length:sizeof(ERDataType)];
//    
//    [data appendBytes:&bodySign length:sizeof(UInt32)];
//    [data appendBytes:&bodyLength length:sizeof(UInt32)];
//    [data appendData:bodyData];
//    
//    return [data copy];
}


/**
 包头生成函数
 @param cmdType 命令字类型
 @param headExtendData 包头扩展数据
 @return 包头数据
 */
- (NSData *)generateHeadWithCmdType:(ERCmdType)cmdType headExtendData:(NSData *)headExtendData
{
    UInt32 headSign = HeadSign;
    HeadLengthType headLength = [self generateHeadlength:cmdType];
    UInt8 headVersion = HeadVersion;
    ERCmdType cmd = cmdType;
    UInt16 headStatus = HeadStatus;
    UInt16 sessionId = (UInt16)self.sessionId;
    UInt32 packetNumber = [self generatePacketNumber:cmdType];
    NSData *timeData = [self generateTimeStampData];
    ERDataType dataType = [self generateDataType:cmdType];
    
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:&headSign length:sizeof(UInt32)];
    [data appendBytes:&headLength length:sizeof(HeadLengthType)];
    [data appendBytes:&headVersion length:sizeof(UInt8)];
    [data appendBytes:&cmd length:sizeof(ERCmdType)];
    [data appendBytes:&headStatus length:sizeof(UInt16)];
    [data appendBytes:&sessionId length:sizeof(UInt16)];
    [data appendBytes:&packetNumber length:sizeof(UInt32)];
    [data appendData:timeData];
    [data appendBytes:&dataType length:sizeof(ERDataType)];
    [data appendData:headExtendData];
    return [data copy];
}


/**
 包体生成函数
 @param bodyData 包体数据
 @return 包体
 */
- (NSData *)generateBodyWithBodyData:(NSData *)bodyData
{
    UInt32 bodySign = BodySign;
    UInt32 bodyLength = (UInt32)[bodyData length] + sizeof(UInt32);
    
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:&bodySign length:sizeof(UInt32)];
    [data appendBytes:&bodyLength length:sizeof(UInt32)];
    [data appendData:bodyData];
    return bodyData ? [data copy] : nil;
}

#pragma mark - 数据包产生辅助函数
- (HeadLengthType)generateHeadlength:(ERCmdType)type
{
    switch (type) {
        case ERCmdTypeWantLocate:
            return HeadLengthTypeNoExtend;
            break;
            
        case ERCmdTypeEndLocate:
            return HeadLengthTypeNoExtend;
            break;
            
        case ERCmdTypeAudioData:
            return HeadLengthTypeAudio;
            break;
         
        case   ERCmdTypeTakePhoto:
            return HeadLengthTypeAudio;
            break;
            
        case ERCmdTypeSceneSwitch:
            return HeadLengthTypeNoExtend;
            break;
            
        default:
            return HeadLengthTypeNoExtend;
            break;
    }
}

- (UInt32)generatePacketNumber:(ERCmdType)type
{
    UInt32 packetNumber = 0;
    switch (type) {
        case ERCmdTypeWantLocate:
        {
            if (_wantLocateNumber == UINT32_MAX) {
                _wantLocateNumber = 0;
            }
            packetNumber = ++_wantLocateNumber;
            break;
        }
            
        case ERCmdTypeEndLocate:
        {
            if (_endLocateNumber == UINT32_MAX) {
                _endLocateNumber = 0;
            }
            packetNumber = ++_endLocateNumber;
            break;
        }
            
        case ERCmdTypeAudioData:
        {
            if (_audioDataNumber == UINT32_MAX) {
                _audioDataNumber = 0;
            }
            packetNumber = ++_audioDataNumber;
            break;
        }
            
        default:
            break;
    }
    
    return packetNumber;
}
#pragma mark-包头长度
- (ERDataType)generateDataType:(ERCmdType)type
{
    switch (type) {
        case ERCmdTypeWantLocate:
            return ERDataTypeString;
            break;
            
        case ERCmdTypeEndLocate:
            return ERDataTypeNo;
            break;
            
        case ERCmdTypeAudioData:
            return ERDataTypeStream;
            break;
            
        case ERCmdTypeSceneSwitch:
            return ERDataTypeString;
            break;
            
        case ERCmdTypeBeginClass:
            return ERDataTypeString;
            break;
            
        case ERCmdTypeEndClass:
            return ERDataTypeString;
            break;
            
        case ERCmdTypeTakePhoto:
            return ERDataTypeString;
            break;
        default:
            return ERDataTypeNo;
            break;
    }
}

- (NSData *)generateTimeStampData
{
    NSTimeInterval utc = [[NSDate date] timeIntervalSince1970];
    UInt32 headUTC = utc * 1000;
    UInt16 headuSecs = (UInt16)(utc * 1000000) % 1000;
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    int8_t headTimeZone = zone.secondsFromGMT / 3600;
    
    NSMutableData *timeData = [[NSMutableData alloc] initWithBytes:&headUTC length:sizeof(UInt32)];
    [timeData appendBytes:&headuSecs length:sizeof(UInt16)];
    [timeData appendBytes:&headTimeZone length:sizeof(int8_t)];
    
    return [timeData copy];
}

#pragma mark - 暂时无用的代码

- (NSData *)generateBackDataPacketWithCmd:(ERCmdType)cmd
{
    return [self generateDataPacketWithCmdType:cmd + CmdDiffer bodyData:nil headExtendData:nil];
}

- (ERBackPacketHead *)comanalyzeHeadData:(NSData *)data
{
//    DEBUG_NSLog(@"%@", data);
    
    ERCmdType cmd = 0;
    UInt16 status = 0;
    ERDataType dataType = 0;
    UInt32 backNumber = 0;
    
    [data getBytes:&cmd range:NSMakeRange(CmdLocation, sizeof(ERCmdType))];
    [data getBytes:&status range:NSMakeRange(StatusLocation, sizeof(UInt16))];
    [data getBytes:&dataType range:NSMakeRange(DataTypeLocation, sizeof(ERDataType))];
    [data getBytes:&backNumber range:NSMakeRange(NumberLocation, sizeof(UInt32))];
    
    BOOL ret = NO;
    if (cmd - CmdDiffer == ERCmdTypeWantLocate) {
        switch (cmd - CmdDiffer) {
            case ERCmdTypeWantLocate:
            {
                if (backNumber == _wantLocateNumber) {
                    ret = YES;
                }
                break;
            }
                
            case ERCmdTypeEndLocate:
            {
                if (backNumber == _endLocateNumber) {
                    ret = YES;
                }
                break;
            }
                
            default:
                break;
        }
        ret = YES;
    }
    
    ERBackPacketHead *backHead = [[ERBackPacketHead alloc] init];
    backHead.cmd = cmd;
    backHead.status = status;
    backHead.dataType = dataType;
    backHead.requestStatus = ret;
//    DEBUG_NSLog(@"backHead==%@",backHead);
    return backHead;
}


- (ERBackPacketHead *)analyzeHeadData:(NSData *)data
{
    
//    DEBUG_NSLog(@"%@", data);

    
    ERCmdType cmd = 0;
    UInt16 status = 0;
    ERDataType dataType = 0;
    UInt32 backNumber = 0;
    
    [data getBytes:&cmd range:NSMakeRange(CmdLocation, sizeof(ERCmdType))];
    [data getBytes:&status range:NSMakeRange(StatusLocation, sizeof(UInt16))];
    [data getBytes:&dataType range:NSMakeRange(DataTypeLocation, sizeof(ERDataType))];
    [data getBytes:&backNumber range:NSMakeRange(NumberLocation, sizeof(UInt32))];
    
    BOOL ret = NO;
    if (cmd - CmdDiffer == ERCmdTypeWantLocate) {
        switch (cmd - CmdDiffer) {
            case ERCmdTypeWantLocate:
            {
                if (backNumber == _wantLocateNumber) {
                    ret = YES;
                }
                break;
            }
                
            case ERCmdTypeEndLocate:
            {
                if (backNumber == _endLocateNumber) {
                    ret = YES;
                }
                break;
            }
                
            default:
                break;
        }
        ret = YES;
    }
    
    ERBackPacketHead *backHead = [[ERBackPacketHead alloc] init];
    backHead.cmd = cmd;
    backHead.status = status;
    backHead.dataType = dataType;
    backHead.requestStatus = ret;
//    DEBUG_NSLog(@"backHead==%@",backHead);
    return backHead;
}

- (BOOL)analyzeBackData:(NSData *)backData
{
    ERCmdType backCmd = 0;
    [backData getBytes:&backCmd range:NSMakeRange(CmdLocation, sizeof(ERCmdType))];
    
    UInt32 backNumber = 0;
    [backData getBytes:&backNumber range:NSMakeRange(NumberLocation, sizeof(UInt32))];
    
    BOOL ret = NO;
    if (backCmd == _lastCmd + CmdDiffer) {
        switch (backCmd) {
            case ERCmdTypeWantLocate:
            {
                if (backNumber == _wantLocateNumber) {
                    ret = YES;
                }
                break;
            }
                
            case ERCmdTypeEndLocate:
            {
                if (backNumber == _endLocateNumber) {
                    ret = YES;
                }
                break;
            }
                
            default:
                break;
        }
    }
    
    return ret;
}



- (ERBackPacketBody *)analyzeSeatsLayoutData:(NSData *)data
{
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *dataString = [[NSString alloc] initWithData:data encoding:encode];
    
    NSArray *stringArray = [dataString componentsSeparatedByString:@"&"];
    NSString *seatmodeSign = @"seatMode=";
    NSString *picurlSign = @"picUrl=";
    NSString *seatSign = @"seat=";
    NSString *seatmode = nil;
    NSString *picurl = nil;
    NSString *seat = nil;
    for (NSString *str in stringArray) {
        if ([str hasPrefix:seatmodeSign]) {
            seatmode = [str substringFromIndex:seatmodeSign.length];
        }
        if ([str hasPrefix:picurlSign]) {
            picurl = [str substringFromIndex:picurlSign.length];
        }
        if ([str hasPrefix:seatSign]) {
            seat = [str substringFromIndex:seatSign.length];
        }
    }
    
    
    NSArray *seats = [seat componentsSeparatedByString:@","];
    ERBackPacketBody *seatLayout = [[ERBackPacketBody alloc] init];
    seatLayout.seatMode = seatmode;
    seatLayout.picUrl = picurl;
    seatLayout.seats = [seats copy];
    
    return seatLayout;

}

@end



@implementation ERBackPacketHead

@end

@implementation ERBackPacketBody
@end

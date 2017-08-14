//
//  LWAudioRecorder.m
//  Laiwang
//
//  Created by 胡 伟 on 12-9-25.
//  Copyright (c) 2012年 Alibaba(China)Technology Co.,Ltd. All rights reserved.
//

#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LWAudioRecorder.h"
#import "AmrFileCodec.h"
//#import "LWGlobalConstant.h"

@implementation LWAudioRecordResult
+ (instancetype)resultWithRecordedFileUrl:(NSURL *)recordedFileUrl
                       recordedAmrFileUrl:(NSURL *)recordedAmrFileUrl
                               recordTime:(CGFloat)recordTime
{
    LWAudioRecordResult *recordResult = [[[self class] alloc] init];
    recordResult.recordedFileUrl = recordedFileUrl;
    recordResult.recordedAmrFileUrl = recordedAmrFileUrl;
    recordResult.recordTime = recordTime;
    return recordResult;
}

@end

#ifdef kLWAudioRecorder_NewVersion
@interface LWAudioRecorder ()<LWAudioRecorderProtocol>
@end
#endif

@implementation LWAudioRecorder

@synthesize lastPlayIdentifier;
@synthesize earphoneModeEnabled;
@synthesize onSwitchToSpeaker;
@synthesize onSwitchToEarphone;
@synthesize onPlayDidStopped;
@synthesize isForceEarphoneMode;

static BOOL isSpeaker = YES;
static BOOL needKeepLastPlayMode = NO;

#pragma mark - life

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:@"UIDeviceProximityStateDidChangeNotification"
                object:nil];
    if (recorder) {
        [recorder stop];
        recorder.delegate = nil;
        recorder = nil;
    }
    
    if (amrplayer) {
        [amrplayer stop];
        amrplayer = nil;
    }
    
    if (avAudioPlayer){
        [avAudioPlayer stop];
        avAudioPlayer.delegate = nil;
        avAudioPlayer = nil;
    }

    _recordedTmpFile = nil;
    _recordedTmpAmrFile = nil;
    onSwitchToSpeaker = nil;
    onSwitchToEarphone = nil;
    onPlayDidStopped = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self audioUnActive];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initAudioSession];
    }
    return self;
}

+ (LWAudioRecorder *)sharedAudioRecorder
{
    static LWAudioRecorder *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)setProximityMonitoringEnabled:(BOOL)isEnabled
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:isEnabled];
}

- (void)initAudioSession
{
    UInt32 mediaPlaybackOverride = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(mediaPlaybackOverride),
                            &mediaPlaybackOverride);

    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride),
                            &audioRouteOverride);

    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];

    // default value is true
    self.isShoudProximityState = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
}

#pragma mark - action

//处理监听触发事件
- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    if (!self.isShoudProximityState)
    {
        return;
    }
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if (isForceEarphoneMode ||
        ([UIDevice currentDevice] != nil && [[UIDevice currentDevice] proximityState] == YES))
    {
        //听筒模式
        if (!isSpeaker)
            return;
        isSpeaker = NO;
        if (onSwitchToEarphone)
        {
            onSwitchToEarphone(lastPlayIdentifier);
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        //如果5s内切换到听筒，则重新播放
        NSTimeInterval currentTime = [self currentTime:lastPlayIdentifier];
        // NSLog(@"currentTime:%f", currentTime);
        if (currentTime < 5)
        {
            [self replay];
        }
    }
    else
    {
        //扬声器模式
        isSpeaker = YES;
        if (onSwitchToSpeaker)
        {
            onSwitchToSpeaker(lastPlayIdentifier);
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)replay
{
    if (amrplayer != nil && [amrplayer isPlaying])
    {
        [amrplayer stop];
        [amrplayer play];
    }
    else if (avAudioPlayer != nil && avAudioPlayer.isPlaying)
    {
        [avAudioPlayer stop];
        avAudioPlayer.currentTime = 0;
        [avAudioPlayer play];
    }
}

/*
   音频会话激活，保障在播放或录音的时候停止后台其他的播放或录制工作
 */
- (void)audioActive
{
    // Activate the session
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
}

/*
 音频会话停止激活，先前在后台其他的播放或录制能够继续工作
 */
- (void)audioUnActive
{
    // Activate the session
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

/*
 获取音频文件的播放时长，单位是秒，amr需要转换成wav后再调用此方法
 @data 表示wav文件数据
 @result 可播放的时长时间
 */
- (NSTimeInterval)getAudioTime:(NSData *)data
{
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithData:data error:nil];
    NSTimeInterval n = [play duration];
    return n;
}

- (void)resetAudioRecorder
{
    self.recordDelegate = nil;
}

- (void)startRecord
{
    [self startRecord:nil amrFilePath:nil];
}
/*
  开始录音
 */
- (void)startRecord:(NSString *)recordFilePath amrFilePath:(NSString *)amrFilePath
{
#ifdef kLWAudioRecorder_NewVersion
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //    dispatch_queue_t playDispatchQueue =
    //    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(playDispatchQueue, ^ {
    //
    //    });
    [self audioActive];
    [self stopPlay];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLWAudioRecorderWillStart
                                                        object:nil];
    recorder = [[ALAudioRecorder alloc] init];
    recorder.delegate = self;
    _recordedTmpFile = [NSURL URLWithString:recordFilePath];
    if (!_recordedTmpFile)
    {
        _recordedTmpFile = [NSURL
            URLWithString:
                [NSTemporaryDirectory()
                    stringByAppendingPathComponent:
                        [NSString stringWithFormat:@"%.0f.%@",
                                                   [NSDate timeIntervalSinceReferenceDate] * 1000.0,
                                                   @"caf"]]];
    }
    _recordedTmpAmrFile = [NSURL URLWithString:amrFilePath];
    ;
    if (!_recordedTmpAmrFile)
    {
        _recordedTmpAmrFile = [NSURL
            URLWithString:
                [NSTemporaryDirectory()
                    stringByAppendingPathComponent:
                        [NSString stringWithFormat:@"%.0f.%@",
                                                   [NSDate timeIntervalSinceReferenceDate] * 1000.0,
                                                   @"amr"]]];
    }

    [recorder setRecordFilePath:_recordedTmpFile.absoluteString];
    [recorder setAmrFilePath:_recordedTmpAmrFile.absoluteString];

    if ([recorder record])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLWAudioRecorderStart
                                                            object:nil];
    }

#else

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    dispatch_queue_t playDispatchQueue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(playDispatchQueue, ^{
        [self audioActive];
        [self stopPlay];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];

        NSDictionary *recordSetting = [NSDictionary
            dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatLinearPCM],
                                         AVFormatIDKey,
                                         //[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                         [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                         [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                         //  [NSData dataWithBytes:&channelLayout
                                         //  length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                         [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                         [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                         [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                         [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                         nil];

        _recordedTmpFile = [NSURL
            fileURLWithPath:
                [NSTemporaryDirectory()
                    stringByAppendingPathComponent:
                        [NSString stringWithFormat:@"%.0f.%@",
                                                   [NSDate timeIntervalSinceReferenceDate] * 1000.0,
                                                   @"caf"]]];
        //        NSLog(@"Using File called: %@", recordedTmpFile.path);

        // Setup the recorder to use this file and record to it.
        LW_RELEASE_SAFELY(recorder);
        NSError *error = nil;
        recorder = [[AVAudioRecorder alloc] initWithURL:_recordedTmpFile
                                               settings:recordSetting
                                                  error:&error];
        [recorder prepareToRecord];
        [recorder setMeteringEnabled:YES];
        if ([recorder record])
        {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kNotificationLWAudioRecorderStart
                              object:nil];
        }
    });
#endif
}

//- (void)releaseRecordResource
//{
//    if (recorder) {
//        [[NSFileManager defaultManager] removeItemAtPath:recorder.url.absoluteString error:nil];
//        [[NSFileManager defaultManager] removeItemAtPath:recorder.amrUrl.absoluteString
//        error:nil];
//    }
//}
//
//- (NSURL *)getAmrFilePath
//{
//    NSURL *url = nil;
//    if (recorder) {
//        url = recorder.amrUrl;
//    }
//    return url;
//}
//
//- (NSURL *)getRecordFilePath
//{
//    NSURL *url = nil;
//    if (recorder) {
//        url = recorder.url;
//    }
//    return url;
//}
//
//- (CGFloat)getRecordAudioDuration
//{
//    CGFloat duration = 0;
//    if (recorder) {
//        duration = recorder.recordTime;
//    }
//    return duration;
//}

/*
 暂停录音
 */
- (LWAudioRecordResult *)stopRecord
{
    LWAudioRecordResult *result = [[LWAudioRecordResult alloc] init];
#ifdef kLWAudioRecorder_NewVersion
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLWAudioRecorderStop
                                                        object:nil];
    if (recorder == nil || recorder.url.absoluteString == nil)
    {
        //[self performSelector:@selector(stopRecord) withObject:nil afterDelay:0.5f];
        return nil;
    }
//    NSString *tt = recorder.url.absoluteString;
//    NSURL *url = [[NSURL alloc] initWithString:recorder.url.absoluteString];
    //[recorder setRecordFilePath:url.absoluteString];

    result.recordTime = recorder.recordTime;
    result.recordedFileUrl = recorder.url;
    result.recordedAmrFileUrl = recorder.amrUrl;
    [recorder stop];
    recorder = nil;

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self audioUnActive];
    return result;
#else
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLWAudioRecorderStop
                                                        object:nil];
    if (recorder == nil || recorder.url.absoluteString == nil)
    {
        //[self performSelector:@selector(stopRecord) withObject:nil afterDelay:0.5f];
        return nil;
    }
    NSURL *url = [[NSURL alloc] initWithString:recorder.url.absoluteString];
    [recorder stop];
    recorder = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    //切换成扬声器模式
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self audioUnActive];

    result.recordTime = 0;
    result.recordedFileUrl = url;
    result.recordedAmrFileUrl = nil;
    return result;
#endif
}

//是否在录音
- (BOOL)isRecording
{
    return [recorder isRecording];
}

// 获取录音的分贝峰值 (-160 ~ 0>)
- (float)peakPowerForChannel
{
    [recorder updateMeters];
    return [recorder peakPowerForChannel:0];
}

// 获取录音的分贝平均值 (-160 ~ 0>)
- (float)averagePowerForChannel
{
    [recorder updateMeters];
    return [recorder averagePowerForChannel:0];
}

//将amr文件格式解码成wave
- (NSData *)decodeAmr:(NSData *)data
{
    if (!data)
    {
        return data;
    }
    return DecodeAMRToWAVE(data);
}

- (void)keepLastPlayMode
{
    needKeepLastPlayMode = YES;
}

/**
 *  播放amr音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *  @param data           amr音频数据
 *  @param playIdentifier 用于定位播放文件的唯一标识
 */
- (void)playAmr:(NSData *)data playIdentifier:(NSUInteger)playIdentifier
{
    [self playAmr:data playIdentifier:playIdentifier withCategory:AVAudioSessionCategoryPlayback];
}

- (void)playAmr:(NSData *)data playIdentifier:(NSUInteger)playIdentifier atTime:(NSTimeInterval)time
{
    [self playAmr:data
                 playIdentifier:playIdentifier
                   withCategory:AVAudioSessionCategoryPlayback
        withProximityMonitoring:YES
                         atTime:time];
}

/**
 *  播放amr音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *  @param data           amr音频数据
 *  @param playIdentifier 用于定位播放文件的唯一标识
 */
- (void)playAmr:(NSData *)data
    playIdentifier:(NSUInteger)playIdentifier
      withCategory:(NSString *)category
{
    [self playAmr:data
                 playIdentifier:playIdentifier
                   withCategory:category
        withProximityMonitoring:YES];
}

- (void)playAmr:(NSData *)data
             playIdentifier:(NSUInteger)playIdentifier
               withCategory:(NSString *)category
    withProximityMonitoring:(BOOL)enabled
{
    [self playAmr:data
                 playIdentifier:playIdentifier
                   withCategory:category
        withProximityMonitoring:enabled
                         atTime:0];
}

/**
 *  播放amr音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *
 *  @param data           amr音频数据
 *  @param playIdentifier 用于定位播放文件的唯一标识
 *  @param category       session category
 *  @param enabled        ProximityMonitoringEnabled
 */
- (void)playAmr:(NSData *)data
             playIdentifier:(NSUInteger)playIdentifier
               withCategory:(NSString *)category
    withProximityMonitoring:(BOOL)enabled
                     atTime:(NSTimeInterval)time
{
    if (enabled || earphoneModeEnabled)
    {
        [self setProximityMonitoringEnabled:YES];
    }
    else
    {
        [self setProximityMonitoringEnabled:NO];
    }

    if (isForceEarphoneMode)
    {
        if (onSwitchToEarphone)
        {
            onSwitchToEarphone(lastPlayIdentifier);
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        if (needKeepLastPlayMode)
        {
            needKeepLastPlayMode = NO;
            if (!isSpeaker)
            {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                                       error:nil];
            }
        }
        else
        {
            [[AVAudioSession sharedInstance] setCategory:category error:nil];
        }
    }
    if ([self isPlaying:playIdentifier])
    {
        [self stopPlay];
    }
    else
    {
        //屏幕保持点亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [self audioActive];
        if (avAudioPlayer != nil && avAudioPlayer.isPlaying)
        {
            [avAudioPlayer stop];
            if (self.onPlayDidStopped && lastPlayIdentifier)
            {
                self.onPlayDidStopped(lastPlayIdentifier, NO);
            }
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kNotificationLWAudioRecorderStop
                              object:nil];
        }
        lastPlayIdentifier = playIdentifier;
        NSData *o = [self decodeAmr:data];
        NSError *error = nil;
        avAudioPlayer = [[AVAudioPlayer alloc] initWithData:o error:&error];
        if (avAudioPlayer == nil)
        {
            //            LWLogErrorType(LOG_TYPE_UI, LogErrorCodeUIError, @"audio play failure.
            //            playIdentifier：%d, errcode: %d", playIdentifier, error.code);
            return;
        }

        avAudioPlayer.delegate = self;
        // self.target = aTarget;
        [avAudioPlayer prepareToPlay];
        if (![avAudioPlayer play])
        {
            [self sendStatus:1];
        }
        else
        {
            if (time > 0)
            {
                avAudioPlayer.currentTime = time;
            }
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kNotificationLWAudioRecorderStart
                              object:nil];
            [self sendStatus:0];
        }
    }
}
/**
 *  播放amr音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *
 *  @param filename       amr音频文件
 *  @param playIdentifier 用于定位播放文件的唯一标识
 *  @param category       session category
 */
- (void)play:(NSString *)filename
    playIdentifier:(NSUInteger)playIdentifier
      withCategory:(NSString *)category
{
    [self play:filename
                 playIdentifier:playIdentifier
                   withCategory:category
        withProximityMonitoring:YES];
}

/**
 *  播放amr音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *
 *  @param filename       amr音频文件
 *  @param playIdentifier 用于定位播放文件的唯一标识
 *  @param category       session category
 *  @param enabled        proximity monitoring
 */
- (void)play:(NSString *)filename
             playIdentifier:(NSUInteger)playIdentifier
               withCategory:(NSString *)category
    withProximityMonitoring:(BOOL)enabled
{
    if (!filename)
    {
        return;
    }
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filename];
    if (data)
    {
        [self playAmr:data
                     playIdentifier:playIdentifier
                       withCategory:category
            withProximityMonitoring:enabled];
    }
}

/**
 *  播放amr音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *
 *  @param filename       amr音频文件
 *  @param playIdentifier 用于定位播放文件的唯一标识
 */
- (void)play:(NSString *)filename playIdentifier:(NSUInteger)playIdentifier
{
    [self play:filename playIdentifier:playIdentifier withCategory:AVAudioSessionCategoryPlayback];
}

/**
 *  播放wav音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放 *
 *  @param waveData       wav音频数据
 *  @param playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 */
- (void)playWave:(NSData *)waveData playIdentifier:(NSUInteger)playIdentifier
{
    [self playWave:waveData
        playIdentifier:playIdentifier
          withCategory:AVAudioSessionCategoryPlayback];
}

/**
 *  播放wav音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  @param waveData       wav音频数据
 *  @param playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *  @param category       session category
 */
- (void)playWave:(NSData *)waveData
    playIdentifier:(NSUInteger)playIdentifier
      withCategory:(NSString *)category
{
    [self playWave:waveData
                 playIdentifier:playIdentifier
                   withCategory:category
        withProximityMonitoring:YES];
}
/**
 *  播放wav音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  @param waveData       wav音频数据
 *  @param playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *  @param category       session category
 */
- (void)playWave:(NSData *)waveData
             playIdentifier:(NSUInteger)playIdentifier
               withCategory:(NSString *)category
    withProximityMonitoring:(BOOL)enabled
{
    if (enabled || earphoneModeEnabled)
    {
        [self setProximityMonitoringEnabled:YES];
    }
    else
    {
        [self setProximityMonitoringEnabled:NO];
    }
    if (isForceEarphoneMode)
    {
        if (onSwitchToEarphone)
        {
            onSwitchToEarphone(lastPlayIdentifier);
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:category error:nil];
    }
    if ([self isPlaying:playIdentifier])
    {
        [self stopPlay];
    }
    else
    {
        //屏幕保持点亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [self audioActive];
        if (avAudioPlayer != nil && avAudioPlayer.isPlaying)
        {
            [avAudioPlayer stop];
            if (self.onPlayDidStopped && lastPlayIdentifier)
            {
                self.onPlayDidStopped(lastPlayIdentifier, NO);
            }
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kNotificationLWAudioRecorderStop
                              object:nil];
        }
        lastPlayIdentifier = playIdentifier;
        NSError *error = nil;
        avAudioPlayer = [[AVAudioPlayer alloc] initWithData:waveData error:&error];
        avAudioPlayer.delegate = self;
        // self.target = aTarget;
        [avAudioPlayer prepareToPlay];
        if (![avAudioPlayer play])
        {
            [self sendStatus:1];
        }
        else
        {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kNotificationLWAudioRecorderStart
                              object:nil];
            [self sendStatus:0];
        }
    }
}
//
//- (void)play:(NSString *)filename playIdentifier:(NSUInteger)playIdentifier
//{
//    @synchronized (self) {
//        [self setProximityMonitoringEnabled:earphoneModeEnabled];
//        [self audioActive];
//        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
//        if ([self isPlaying:playIdentifier]) {
//            [self stopPlay];
//        } else {
//            [self stopPlay];
//            lastPlayIdentifier = playIdentifier;
//            __block typeof(self) bself = self;
//            amrplayer = [[LWAMRPlayer alloc] initWithFileName:filename];
//            amrplayer.onAudioPlayerDidFinishPlaying = ^(BOOL successfully){
//                [bself setProximityMonitoringEnabled:NO];
//                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
//                error:nil];
//                if (bself.onPlayDidStopped) {
//                    bself.onPlayDidStopped(bself.lastPlayIdentifier, successfully);
//                }
//                //[[AVAudioSession sharedInstance] setActive:NO];
//                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//            };
//            if (![amrplayer play]) {
//                [self sendStatus:1];
//            } else {
//                [self sendStatus:0];
//            }
//        }
//    }
//}

/*
 0 播放 1 播放完成 2出错
 */
- (void)sendStatus:(int)status
{
    if (status != 0)
    {
        [self setProximityMonitoringEnabled:NO];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (amrplayer != nil)
        {
            [amrplayer stop];
            amrplayer = nil;
        }
        if (avAudioPlayer != nil && avAudioPlayer.isPlaying)
        {
            [avAudioPlayer stop];
            [[NSNotificationCenter defaultCenter]
                postNotificationName:kNotificationLWAudioRecorderStop
                              object:nil];
            if (self.onPlayDidStopped)
            {
                self.onPlayDidStopped(lastPlayIdentifier, NO);
            }
            [self audioUnActive];
        }
    }
}

/*
 检查指定的播放标识当前是否处于播放状态
 */
- (BOOL)isPlaying:(NSUInteger)playIdentifier
{
    return (amrplayer != nil && amrplayer.isPlaying && playIdentifier == lastPlayIdentifier) ||
           (avAudioPlayer != nil && avAudioPlayer.isPlaying &&
            playIdentifier == lastPlayIdentifier);
}

- (BOOL)isPlaying
{
    return (amrplayer != nil && amrplayer.isPlaying) ||
           (avAudioPlayer != nil && avAudioPlayer.isPlaying);
}

//停止播放
- (void)stopPlay
{
    @synchronized(self)
    {
        if (amrplayer != nil || avAudioPlayer != nil)
        {
            [self sendStatus:1];
            amrplayer = nil;
            avAudioPlayer = nil;
        }
    }
}

/*
 audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method
 is NOT called if the player is stopped due to an interruption.
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self setProximityMonitoringEnabled:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    if (self.onPlayDidStopped)
    {
        self.onPlayDidStopped(lastPlayIdentifier, flag);
    }
    [self audioUnActive];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLWAudioRecorderStop
                                                        object:nil];
}

/*
 当前已播放过的时间
 */
- (NSTimeInterval)currentTime:(NSUInteger)playIdentifier
{
    if ([self isPlaying:playIdentifier] == NO)
    {
        return 0;
    }
    else
    {
        if (amrplayer != nil)
        {
            return amrplayer.currentTime;
        }
        if (avAudioPlayer != nil)
        {
            return avAudioPlayer.currentTime;
        }
        return 0;
    }
}

- (NSTimeInterval)duration:(NSUInteger)playIdentifier
{
    if ([self isPlaying:playIdentifier] == NO)
    {
        return 0;
    }
    else
    {
        if (amrplayer != nil)
        {
            return 0;
        }
        if (avAudioPlayer != nil)
        {
            return avAudioPlayer.duration;
        }
        return 0;
    }
}

- (CGFloat)progress:(NSUInteger)playIdentifier;
{
    if ([self isPlaying:playIdentifier] == NO)
    {
        return 0;
    }
    if (avAudioPlayer != nil)
    {
        return avAudioPlayer.currentTime / avAudioPlayer.duration;
    }
    return 0;
}
#ifdef kLWAudioRecorder_NewVersion
#pragma mark - ALAudioRecoderDelegate

- (void)audioRecorderDidStartRecording:(ALAudioRecorder *)audioRecorder
{
    if ([audioRecorder.url.absoluteString isEqualToString:_recordedTmpFile.absoluteString] &&
        self.recordDelegate &&
        [self.recordDelegate respondsToSelector:@selector(audioRecorderDidStartRecording:)])
    {
        [self.recordDelegate audioRecorderDidStartRecording:audioRecorder];
    }
}

- (void)audioRecorderDidRecord:(ALAudioRecorder *)audioRecorder
                  recordBuffer:(const char *)buffer
                  recordLength:(int)nRecordDataLen
             encodeAmrAudioLen:(int)nEncodeLen
             totalAmrEncodeLen:(int)nTotalEncodeLen
{
    if ([audioRecorder.url.absoluteString isEqualToString:_recordedTmpFile.absoluteString] &&
        self.recordDelegate &&
        [self.recordDelegate respondsToSelector:@selector(audioRecorderDidRecord:
                                                                    recordBuffer:
                                                                    recordLength:
                                                               encodeAmrAudioLen:
                                                               totalAmrEncodeLen:)])
    {
        [self.recordDelegate audioRecorderDidRecord:audioRecorder
                                       recordBuffer:buffer
                                       recordLength:nRecordDataLen
                                  encodeAmrAudioLen:nEncodeLen
                                  totalAmrEncodeLen:nTotalEncodeLen];
    }
}

- (void)audioRecorderDidFinishRecording:(ALAudioRecorder *)audioRecorder successfully:(BOOL)flag
{
    if ([audioRecorder.url.absoluteString isEqualToString:_recordedTmpFile.absoluteString] &&
        self.recordDelegate &&
        [self.recordDelegate
            respondsToSelector:@selector(audioRecorderDidFinishRecording:successfully:)])
    {
        [self.recordDelegate audioRecorderDidFinishRecording:audioRecorder successfully:flag];
    }
}

- (void)audioRecorderTrackTime:(CGFloat)time
{
    if (self.recordDelegate &&
        [self.recordDelegate respondsToSelector:@selector(audioRecorderTrackTime:)])
    {
        [self.recordDelegate audioRecorderTrackTime:time];
    }
}

- (AVAudioPlayer *)player
{
    return avAudioPlayer;
}
#endif
@end

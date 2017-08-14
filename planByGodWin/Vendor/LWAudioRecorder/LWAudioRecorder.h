//
//  LWAudioRecorder.h
//  Laiwang
//
//  Created by 胡 伟 on 12-9-25.
//  Copyright (c) 2012年 Alibaba(China)Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "LWAMRPlayer.h"
#import "ALAudioRecorder.h"
#import "LWAudioRecorderProtocol.h"

#define kLWAudioRecorder_NewVersion

#define kNotificationLWAudioRecorderWillStart @"kNotificationLWAudioRecorderWillStart"
#define kNotificationLWAudioRecorderStart @"kNotificationLWAudioRecorderStart"
#define kNotificationLWAudioRecorderStop @"kNotificationLWAudioRecorderStop"

@class LWAudioRecorder;

@interface LWAudioRecordResult : NSObject
@property (nonatomic, copy) NSURL *recordedFileUrl;
@property (nonatomic, copy) NSURL *recordedAmrFileUrl;
@property (nonatomic, assign) CGFloat recordTime;
+ (instancetype)resultWithRecordedFileUrl:(NSURL *)recordedFileUrl
                       recordedAmrFileUrl:(NSURL *)recordedAmrFileUrl
                               recordTime:(CGFloat)recordTime;
@end

@interface LWAudioRecorder : NSObject<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    NSURL *_recordedTmpFile;
    NSURL *_recordedTmpAmrFile;
#ifdef kLWAudioRecorder_NewVersion
    ALAudioRecorder *recorder;
#else
    AVAudioRecorder *recorder;
#endif
    LWAMRPlayer *amrplayer;
    AVAudioPlayer *avAudioPlayer;
    NSUInteger lastPlayIdentifier;
    BOOL earphoneModeEnabled;
}

@property (nonatomic, assign, readonly) NSUInteger lastPlayIdentifier;
@property (nonatomic, assign) BOOL earphoneModeEnabled;
@property (nonatomic, assign) BOOL isForceEarphoneMode;
@property (nonatomic, readonly) NSURL *recordedTmpFile;
@property (nonatomic, readonly) NSURL *recordedTmpAmrFile;
@property (nonatomic, readonly) AVAudioPlayer *player;

@property (nonatomic, weak) id<LWAudioRecorderProtocol> recordDelegate;

/**
 *  是否响应监听红外感应器的通知方法,默认YES
 */
@property (nonatomic, assign) BOOL isShoudProximityState;

/**
 *  切换到扬声器状态下，可以触发此事件
 */
@property (readwrite, nonatomic, copy) void (^onSwitchToSpeaker)(NSUInteger playIdentifier);
/**
 *  切换到听筒状态下，可以触发此事件
 */
@property (readwrite, nonatomic, copy) void (^onSwitchToEarphone)(NSUInteger playIdentifier);
/**
 *  播放停止的回调，isFinished表示正常播放结束
 */
@property (readwrite, nonatomic, copy) void (^onPlayDidStopped)
    (NSUInteger playIdentifier, BOOL isFinished);

+ (LWAudioRecorder *)sharedAudioRecorder;

//获取音频文件的播放时长，单位是秒
- (NSTimeInterval)getAudioTime:(NSData *)data;

//开始录音
- (void)startRecord;
- (void)startRecord:(NSString *)recordFilePath amrFilePath:(NSString *)amrFilePath;
- (void)resetAudioRecorder;
//暂停录音
- (LWAudioRecordResult *)stopRecord;

////删除录音的一些文件
//- (void)releaseRecordResource;
//
//- (NSURL *)getAmrFilePath;
//- (NSURL *)getRecordFilePath;
//- (CGFloat)getRecordAudioDuration;

//是否在录音
- (BOOL)isRecording;

// 获取录音的分贝峰值 (-160 ~ 0>)
- (float)peakPowerForChannel;

// 获取录音的分贝平均值 (-160 ~ 0>)
- (float)averagePowerForChannel;

//将amr文件格式解码成wave
- (NSData *)decodeAmr:(NSData *)data;

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
      withCategory:(NSString *)category;

- (void)play:(NSString *)filename
             playIdentifier:(NSUInteger)playIdentifier
               withCategory:(NSString *)category
    withProximityMonitoring:(BOOL)enabled;

/*
 优化的播放amr音频文件的方式推荐采用此方法此方法可以一边解码一边播放效率高，
 如果当前已经处于播放状态，那么就将其暂停掉然后继续播放

 @filename 表示要播放的文件
 @playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 */
- (void)play:(NSString *)filename playIdentifier:(NSUInteger)playIdentifier;

/**
 *  播放amr音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *  @param data           amr音频数据
 *  @param playIdentifier 用于定位播放文件的唯一标识
 *  @param category       session category
 */
- (void)playAmr:(NSData *)data
    playIdentifier:(NSUInteger)playIdentifier
      withCategory:(NSString *)category;
- (void)playAmr:(NSData *)data
             playIdentifier:(NSUInteger)playIdentifier
               withCategory:(NSString *)category
    withProximityMonitoring:(BOOL)enabled;
/**
 *  播放amr音频，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *
 *  @param data           表示要播放的数据
 *  @param playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 */
- (void)playAmr:(NSData *)data playIdentifier:(NSUInteger)playIdentifier;

- (void)playAmr:(NSData *)data
    playIdentifier:(NSUInteger)playIdentifier
            atTime:(NSTimeInterval)time;

/**
 *  播放wav音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  @param waveData       wav音频数据
 *  @param playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 */
- (void)playWave:(NSData *)waveData playIdentifier:(NSUInteger)playIdentifier;

/**
 *  播放wav音频文件，如果当前已经处于播放状态，那么就将其暂停掉然后继续播放
 *  @param waveData       wav音频数据
 *  @param playIdentifier 表示当前播放的唯一标识，用于在后面检测当前哪个音频处于播放阶段
 *  @param category       session category
 */
- (void)playWave:(NSData *)waveData
    playIdentifier:(NSUInteger)playIdentifier
      withCategory:(NSString *)category;
- (void)playWave:(NSData *)waveData
             playIdentifier:(NSUInteger)playIdentifier
               withCategory:(NSString *)category
    withProximityMonitoring:(BOOL)enabled;

//检查指定的播放标识当前是否处于播放状态
- (BOOL)isPlaying:(NSUInteger)playIdentifier;

- (BOOL)isPlaying;

//停止播放
- (void)stopPlay;

//沿用最后一次播放的模式，比如扬声器或听筒模式，通常在playXXX方法之前执行
- (void)keepLastPlayMode;

//当前已播放过的时间
- (NSTimeInterval)currentTime:(NSUInteger)playIdentifier;

- (NSTimeInterval)duration:(NSUInteger)playIdentifier;

- (CGFloat)progress:(NSUInteger)playIdentifier;

@end

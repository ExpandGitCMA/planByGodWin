//
//  ALAudioRecorder.h
//  LWAudioRecord
//
//  Created by guodi.ggd on 4/9/14.
//  Copyright (c) 2014 guodi.ggd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWAudioRecorderProtocol.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

#define kNumberOfRecordBuffers 3
@class ALAudioRecorder;

@interface ALAudioRecorder : NSObject
{
    AudioStreamBasicDescription         _recordFormat;
    AudioQueueRef                       _audioQueue;
    AudioQueueBufferRef                 _audioQueueBuffers[kNumberOfRecordBuffers];
    AudioFileID                         _recordFileID;
    UInt32                              _recordBufferByteSize;
    UInt32                              _recordPacketNum;
    
    CGFloat                             _recordTime;
    BOOL                                _isRunning;
    
    NSString                            *_recordFilePath;
    NSString                            *_amrFilePath;
    
    NSMutableData                       *_unencodeDataBuffer;
}

@property (nonatomic, assign) CGFloat recordTime;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURL *amrUrl;

@property (nonatomic, weak) id <LWAudioRecorderProtocol> delegate;

- (void)setRecordFilePath:(NSString *)filePath;     //设置录音原始文件的path，如果不设置，默认为record目录下某个唯一性的文件路径
- (void)setAmrFilePath:(NSString *)filePath;        //设置amr文件的path，如果不设置，默认为record目录下某个唯一性的文件路径(amr后缀）

- (void)updateMeters;
- (float)averagePowerForChannel:(int)channelNumber;
- (float)peakPowerForChannel:(int)channelNumber;

- (BOOL)record;
- (void)stop;
- (BOOL)isRecording;
@end

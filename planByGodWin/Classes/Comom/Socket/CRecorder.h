//
//  CRecorder.h
//  AudioTracker
//
//  Created by 宁伟 on 16/5/18.
//  Copyright © 2016年 NingWei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

#define kNumberBuffers    3

typedef struct _AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];

    int                         run;
    
} AQCallbackStruct;

@protocol CRecDelegate <NSObject>
- (void) OnAudioData:(AudioQueueBufferRef) buffer;
@end

@interface CRecorder : NSObject{
    id<CRecDelegate> _delegate;
    AQCallbackStruct _aqc;
}

- (id) initWithSampleRate:(id)delegt withSampleRate:(NSInteger)sampleRate atChannels:(UInt32)channels;
- (void) start;
- (void) stop;
- (void) pause;
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (nonatomic, assign) id<CRecDelegate> delegate;

@end

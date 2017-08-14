//
//  LWAudioRecorderProtocol.h
//  Laiwang
//
//  Created by caolidong on 14-4-16.
//  Copyright (c) 2014年 Alibaba(China)Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALAudioRecorder;

@protocol LWAudioRecorderProtocol <NSObject>

@optional

- (void)audioRecorderWillStartRecording:(ALAudioRecorder *)recorder;
- (void)audioRecorderDidStartRecording:(ALAudioRecorder *)recorder;

- (void)audioRecorderDidRecord:(ALAudioRecorder *)recorder
                  recordBuffer:(const char *)buffer
                  recordLength:(int)nRecordDataLen
             encodeAmrAudioLen:(int)nEncodeLen
             totalAmrEncodeLen:(int)nTotalEncodeLen;

- (void)audioRecorderDidFinishRecording:(ALAudioRecorder *)recorder successfully:(BOOL)flag;

//实时跟踪录制时长
- (void)audioRecorderTrackTime:(CGFloat)time;

@end

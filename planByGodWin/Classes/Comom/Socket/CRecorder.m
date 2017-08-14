//
//  CRecorder.m
//  AudioTracker
//
//  Created by 宁伟 on 16/5/18.
//  Copyright © 2016年 NingWei. All rights reserved.
//

#import "CRecorder.h"


@implementation CRecorder
@synthesize aqc;
@synthesize delegate;

static void AQInputCallback (void *inUserData,
                             AudioQueueRef  inAudioQueue,
                             AudioQueueBufferRef inBuffer,
                             const AudioTimeStamp *inStartTime,UInt32 inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc)
{
    CRecorder * engine = (__bridge CRecorder *) inUserData;
    if (inNumPackets > 0)
    {
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
        
    }
    if (engine.aqc.run == 1)
    {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}



- (id) initWithSampleRate:(id)delegt withSampleRate:(NSInteger)sampleRate atChannels:(UInt32)channels
{
    if (aqc.run == 1)
    {
        return self;
    }
    
    self = [super init];
    if (self)
    {
        self.delegate = delegt;
        aqc.mDataFormat.mSampleRate = sampleRate;
        aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormat.mBitsPerChannel = 16;//8 * sizeof(SInt16);
        aqc.mDataFormat.mChannelsPerFrame = channels;
        aqc.mDataFormat.mBytesPerFrame = channels * (aqc.mDataFormat.mBitsPerChannel / 8);
       
        aqc.mDataFormat.mFramesPerPacket = 1;
        aqc.mDataFormat.mBytesPerPacket = aqc.mDataFormat.mBytesPerFrame * aqc.mDataFormat.mFramesPerPacket;
        
        //创建一个录音音频队列对象
        AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void*)(self), NULL, kCFRunLoopCommonModes, 0, &aqc.queue);
 
      
        //每次读取帧数
        for (int i = 0; i < kNumberBuffers; i++)
        {
            //请求音频队列对象来分配一个音频队列缓存。
            AudioQueueAllocateBuffer(aqc.queue, 1280, &aqc.mBuffers[i]);
            //给录音或者回放音频队列的缓存中添加一个缓存数据
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }
        aqc.run = 1;

    }
    return self;
} 


- (void) start
{
    AudioQueueStart(aqc.queue, NULL);
}

- (void) stop
{
    AudioQueueStop(aqc.queue, true);
    AudioQueueDispose(aqc.queue, true);
}

- (void) pause
{
    AudioQueuePause(aqc.queue);
}

- (void) dealloc
{
    self.delegate = nil;
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
    DEBUG_NSLog(@"dealloc=%s",__func__); 
}

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    //long size = buffer->mAudioDataByteSize / aqc.mDataFormat.mBytesPerPacket;
    //NSData *codeData = [[NSData alloc] initWithBytes:data length:size];
    //NSLog(@"%@", codeData);
   //        DEBUG_NSLog(@"processAudioData :%u", (unsigned int)buffer->mAudioDataByteSize);
    
    if (buffer->mAudioDataByteSize) {
//        DEBUG_NSLog(@"processAudioData =:%u", (unsigned int)buffer->mAudioDataByteSize);
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(OnAudioData:)]) {
        [self.delegate OnAudioData:buffer];
    }
}


@end

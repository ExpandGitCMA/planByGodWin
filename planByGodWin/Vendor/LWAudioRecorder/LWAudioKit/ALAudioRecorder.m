//
//  ALAudioRecorder.m
//  LWAudioRecord
//
//  Created by guodi.ggd on 4/9/14.
//  Copyright (c) 2014 guodi.ggd. All rights reserved.
//

#import "ALAudioRecorder.h"
#import <AudioToolbox/AudioToolbox.h>
#include <ctype.h>
#import "AMRFileCodecHandler.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface ALAudioRecorder ()
{
    AMRFileCodecHandler *_amrFileCodecHander;
}
@property (nonatomic, copy) NSString *amrFilePath;
@property (nonatomic, copy) NSString *recordFilePath;
@property (nonatomic, readonly) AudioQueueRef audioQueue;
@property (nonatomic, readonly) AudioFileID recordFileID;
@property (nonatomic, readonly) AudioStreamBasicDescription recordFormat;
@property (nonatomic, assign) UInt32 recordPacketNum;
@property (nonatomic, strong) NSMutableData *unencodeDataBuffer;

- (void)encodeDataToAmrFile:(AudioQueueBufferRef)inBuffer;
@end

void handleAudioQueueInputCallBack(void *inUserData, AudioQueueRef inAQ,
                                   AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,
                                   UInt32 inNumberPacket,
                                   const AudioStreamPacketDescription *inPacketDescs)
{
    @autoreleasepool
    {
        ALAudioRecorder *audioRecorder = (__bridge ALAudioRecorder *)inUserData;
        if (inNumberPacket > 0)
        {
            AudioFileWritePackets(audioRecorder.recordFileID, false, inBuffer->mAudioDataByteSize,
                                  inPacketDescs, audioRecorder.recordPacketNum, &inNumberPacket,
                                  inBuffer->mAudioData);
            // NSLog(@"%d", (unsigned int)inNumberPacket);
            audioRecorder.recordPacketNum += inNumberPacket;

            if (inStartTime != NULL && (inStartTime->mFlags & kAudioTimeStampSampleTimeValid) > 0)
            {
                audioRecorder.recordTime =
                    inStartTime->mSampleTime / audioRecorder.recordFormat.mSampleRate;
                if (audioRecorder.delegate &&
                    [audioRecorder.delegate respondsToSelector:@selector(audioRecorderTrackTime:)])
                {
                    [audioRecorder.delegate audioRecorderTrackTime:audioRecorder.recordTime];
                }
            }

            [audioRecorder encodeDataToAmrFile:inBuffer];

            if ([audioRecorder isRecording])
            {
                AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
            }
        }
    }
}

@implementation ALAudioRecorder
+ (void)initialize
{
    //这里创建那个文件夹record目录
}

- (id)init
{
    if (self = [super init])
    {
        [AVAudioSession sharedInstance];
        OSStatus status = AudioSessionInitialize(NULL, NULL, NULL, NULL);
        if (status != noErr)
        {
            DEBUG_NSLog(@"初始化AudioSession失败");
        }
        _amrFileCodecHander = [[AMRFileCodecHandler alloc] init];
        _isRunning = NO;
    }
    return self;
}

- (void)resetMembers
{
    _recordTime = 0.0f;
    _recordPacketNum = 0;
    _isRunning = NO;
    self.unencodeDataBuffer = nil;
}

- (BOOL)record
{
    if ([self isRecording])
    {
        [self stop];
    }

    [self tryInitFilePath];
    if (!_recordFilePath)
    {
        NSAssert(_recordFilePath, @"录音的目标文件不能为空");
        return NO;
    }

    // 切换录音category
    [self turnToRecordAudioCategory];

    //初始化recordformat对象
    [self initRecordFormat];

    OSStatus status = AudioQueueNewInput(&_recordFormat, handleAudioQueueInputCallBack,
                                         (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
    
    if (status != noErr)
    {
        return NO;
    }

    [self resetMembers];
    // 更新record format
    UInt32 size = sizeof(_recordFormat);
    status = AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_StreamDescription,
                                   &_recordFormat, &size);
    if (status != noErr)
    {
        return NO;
    }

    CFURLRef fileUrlRef =
        CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)_recordFilePath, NULL);
    status = AudioFileCreateWithURL(fileUrlRef, kAudioFileCAFType, &_recordFormat,
                                    kAudioFileFlags_EraseFile, &_recordFileID);
    if (status != noErr)
    {
        if (fileUrlRef)
        {
            CFRelease(fileUrlRef);
        }
        return NO;
    }
    if (fileUrlRef)
    {
        CFRelease(fileUrlRef);
    }

    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(audioRecorderWillStartRecording:)])
    {
        [self.delegate audioRecorderWillStartRecording:self];
    }

    [self parepareEncodeAmrFile];

    [self setupAudioQueueBuffer];

    [self audioActive];

    [self enableUpdateLevelMetering];

    status = AudioQueueStart(_audioQueue, NULL);
    if (status != noErr)
    {
        DEBUG_NSLog(@"error AudioQueueStart status = %d", (int)status);
        CFRelease(fileUrlRef);
        return NO;
    }
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(audioRecorderDidStartRecording:)])
    {
        [self.delegate audioRecorderDidStartRecording:self];
    }
    _isRunning = YES;
    return YES;
}

- (BOOL)enableUpdateLevelMetering
{
    UInt32 val = 1;
    OSStatus status = AudioQueueSetProperty(_audioQueue, kAudioQueueProperty_EnableLevelMetering,
                                            &val, sizeof(UInt32));
    if (status == kAudioSessionNoError)
    {
        return YES;
    }

    return NO;
}

- (void)updateMeters
{
}

- (float)peakPowerForChannel:(int)channelNumber
{
    float averagePower = 0.0;
    if (_recordFormat.mChannelsPerFrame > 0 && _recordFormat.mChannelsPerFrame > channelNumber)
    {
        UInt32 data_sz = sizeof(AudioQueueLevelMeterState) * _recordFormat.mChannelsPerFrame;
        AudioQueueLevelMeterState aq_meterStates[_recordFormat.mChannelsPerFrame];
        memset(aq_meterStates, 0, data_sz);
        OSStatus status = AudioQueueGetProperty(
            _audioQueue, kAudioQueueProperty_CurrentLevelMeterDB, aq_meterStates, &data_sz);
        if (status == kAudioSessionNoError)
        {
            averagePower = aq_meterStates[channelNumber].mPeakPower;
        }
    }
    //    DEBUG_NSLog(@"%lf", averagePower);
    return averagePower;
}

- (float)averagePowerForChannel:(int)channelNumber
{
    float averagePower = 0.0;
    if (_recordFormat.mChannelsPerFrame > 0 && _recordFormat.mChannelsPerFrame > channelNumber)
    {
        UInt32 data_sz = sizeof(AudioQueueLevelMeterState) * _recordFormat.mChannelsPerFrame;
        AudioQueueLevelMeterState aq_meterStates[_recordFormat.mChannelsPerFrame];
        memset(aq_meterStates, 0, data_sz);
        OSStatus status = AudioQueueGetProperty(
            _audioQueue, kAudioQueueProperty_CurrentLevelMeterDB, aq_meterStates, &data_sz);
        if (status == kAudioSessionNoError)
        {
            averagePower = aq_meterStates[channelNumber].mAveragePower;
        }
    }
    //    DEBUG_NSLog(@"%lf", averagePower);
    return averagePower;
}

- (void)parepareEncodeAmrFile
{
    if (self.amrFilePath)
    {
        // PrepareEncode([self.amrFilePath UTF8String]);
        [_amrFileCodecHander PrepareEncode:[self.amrFilePath UTF8String]];
    }
}

- (NSURL *)amrUrl
{
    NSURL *url = [NSURL URLWithString:self.amrFilePath]; //[NSURL URLWithString:];
    return url;
}

- (NSURL *)url
{
    return [NSURL URLWithString:self.recordFilePath];
}

- (void)encodeDataToAmrFile:(AudioQueueBufferRef)inBuffer
{
    [self.unencodeDataBuffer appendBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
    int nDataLen = (int)[self.unencodeDataBuffer length];
    const char *buffer = [self.unencodeDataBuffer bytes];

    // int nEncodeLen = EncodeData(buffer, nDataLen);
    int nEncodeLen = [_amrFileCodecHander EncodeData:buffer dataLen:nDataLen];
    int nTotalEncodeLen = _amrFileCodecHander.writeBytes;
    buffer += nEncodeLen;
    self.unencodeDataBuffer = [NSMutableData dataWithBytes:buffer length:nDataLen - nEncodeLen];

    // DEBUG_NSLog(@"size: [%d]   time: [%lf]", _amrFileCodecHander.writeBytes, self.recordTime);

    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderDidRecord:
                                                                               recordBuffer:
                                                                               recordLength:
                                                                          encodeAmrAudioLen:
                                                                          totalAmrEncodeLen:)])
    {
        [self.delegate audioRecorderDidRecord:self
                                 recordBuffer:(const char *)buffer
                                 recordLength:nDataLen
                            encodeAmrAudioLen:nDataLen - nEncodeLen
                            totalAmrEncodeLen:nTotalEncodeLen];
    }
}

- (void)endEncodeAmrFile
{
    [self copyEncoderCookieToFile];

    int nDataLen = (int)[self.unencodeDataBuffer length];
    if (nDataLen > 0)
    {
        const char *buffer = [self.unencodeDataBuffer bytes];
        // EncodeData(buffer, nDataLen);
        [_amrFileCodecHander EncodeData:buffer dataLen:nDataLen];
    }

    [_amrFileCodecHander EndEncode];
    self.unencodeDataBuffer = nil;
}

- (void)copyEncoderCookieToFile
{
    UInt32 propertySize;
    // get the magic cookie, if any, from the converter
    OSStatus err =
        AudioQueueGetPropertySize(_audioQueue, kAudioQueueProperty_MagicCookie, &propertySize);

    // we can get a noErr result and also a propertySize == 0
    // -- if the file format does support magic cookies, but this file doesn't have one.
    if (err == noErr && propertySize > 0)
    {
        Byte *magicCookie = NULL; // new Byte[propertySize];

        NSMutableData *dataBuf = [[NSMutableData alloc] init];
        [dataBuf setLength:propertySize];
        [dataBuf getBytes:&magicCookie];
        magicCookie = [dataBuf mutableBytes];

        UInt32 magicCookieSize;
        AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_MagicCookie, magicCookie,
                              &propertySize);
        magicCookieSize = propertySize; // the converter lies and tell us the wrong size

        // now set the magic cookie on the output file
        UInt32 willEatTheCookie = false;
        // the converter wants to give us one; will the file take it?
        err = AudioFileGetPropertyInfo(_recordFileID, kAudioFilePropertyMagicCookieData, NULL,
                                       &willEatTheCookie);
        if (err == noErr && willEatTheCookie)
        {
            AudioFileSetProperty(_recordFileID, kAudioFilePropertyMagicCookieData,
                                 magicCookieSize, magicCookie);
//            err = AudioFileSetProperty(_recordFileID, kAudioFilePropertyMagicCookieData,
//                                       magicCookieSize, magicCookie);
        }

        magicCookie = NULL;
    }
}

- (void)stop
{
    if (![self isRecording])
    {
        return;
    }

    AudioQueueStop(_audioQueue, true);
    _isRunning = NO;

    [self endEncodeAmrFile];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:successfully:)])
    {
        [self.delegate audioRecorderDidFinishRecording:self successfully:YES];
    }

    AudioQueueDispose(_audioQueue, true);
    AudioFileClose(_recordFileID);
    [self audioInactive];
}

- (void)dealloc
{
    if (_audioQueue)
    {
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true); // dispose audio queue also dispose its
                                              // audioQueueBuffer  ==>
                                              // AudioQueueFreeBuffer(_audioQueue,
                                              // _audioQueueBuffers);
    }
    if (_recordFileID)
    {
        AudioFileClose(_recordFileID);
    }
    if (_isRunning)
    {
        NSError *err = nil;
        [[AVAudioSession sharedInstance] setActive:NO error:&err];
        if (err)
        {
            DEBUG_NSLog(@"%@", err);
        }
    }
}

- (void)tryInitFilePath
{
    if (!_recordFilePath)
    {
        NSString *strFileName = [NSString
            stringWithFormat:@"%d", (int)([[NSDate date] timeIntervalSinceReferenceDate] * 1000)];
        _recordFilePath =
            [NSTemporaryDirectory() stringByAppendingPathComponent:(NSString *)strFileName];
    }

    if (!_amrFilePath)
    {
        NSString *strFileName = [NSString
            stringWithFormat:@"%d.amr",
                             (int)([[NSDate date] timeIntervalSinceReferenceDate] * 1000)];
        _amrFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:strFileName];
    }
}

- (void)setRecordFilePath:(NSString *)filePath
{
    _recordFilePath = filePath;
}

- (void)setAmrFilePath:(NSString *)filePath
{
    _amrFilePath = filePath;
}

- (void)setupAudioQueueBuffer
{

    UInt32 bufferByteSize = [self calcBufferSize:&_recordFormat seconds:.2];
    for (int i = 0; i < kNumberOfRecordBuffers; i++)
    {
        OSStatus status =
            AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioQueueBuffers[i]);
        if (status != 0)
        {
            DEBUG_NSLog(@"failed to alloc buffer");
        }
        AudioQueueEnqueueBuffer(_audioQueue, _audioQueueBuffers[i], 0, NULL);
    }
}

- (BOOL)isRecording
{
    return _isRunning;
}

- (void)initRecordFormat
{
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    _recordFormat.mSampleRate = 8000;
    _recordFormat.mFormatID = kAudioFormatLinearPCM;
    _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    _recordFormat.mBitsPerChannel = 16;
    _recordFormat.mChannelsPerFrame = 1;
    _recordFormat.mBytesPerFrame =
        _recordFormat.mChannelsPerFrame * (_recordFormat.mBitsPerChannel / 8);
    _recordFormat.mReserved = 0;
    _recordFormat.mFramesPerPacket = 1;
    _recordFormat.mBytesPerPacket = _recordFormat.mFramesPerPacket * _recordFormat.mBytesPerFrame;
}

- (void)turnToRecordAudioCategory
{
    if ([self isOSVersionGreatOrEqualTo:7.0])
    {
        NSError *err = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                               error:&err];
    }
    else
    {
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    }
}

- (void)audioActive
{
    NSError *err = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&err];
    if (err)
    {
        DEBUG_NSLog(@"%@", err);
    }
}

- (void)audioInactive
{
    NSError *err = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&err];
    if (err)
    {
//        [[AVAudioSession sharedInstance] setActive:YES error:&err];
        DEBUG_NSLog(@"%@", err);
    }
    

    
}

- (BOOL)isOSVersionGreatOrEqualTo:(CGFloat)ver
{
    return YES;
}

- (UInt32)calcBufferSize:(const AudioStreamBasicDescription *)format seconds:(CGFloat)seconds
{
    int packets, frames, bytes = 0;
    frames = (int)ceil(seconds * format->mSampleRate);

    if (format->mBytesPerFrame > 0)
    {
        bytes = frames * format->mBytesPerFrame;
    }
    else
    {
        UInt32 maxPacketSize = 0;
        if (format->mBytesPerPacket > 0)
        {
            maxPacketSize = format->mBytesPerPacket; // constant packet size
        }

        if (format->mFramesPerPacket > 0)
        {
            packets = frames / format->mFramesPerPacket;
        }
        else
        {
            packets = frames; // worst-case scenario: 1 frame in a packet
        }

        if (packets == 0) // sanity check
        {
            packets = 1;
        }

        bytes = packets * maxPacketSize;
    }

    return bytes;
}

@end

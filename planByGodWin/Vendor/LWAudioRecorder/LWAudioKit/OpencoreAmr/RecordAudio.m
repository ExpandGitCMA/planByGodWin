//
//  RecordAudio.m
//  JuuJuu
//
//  Created by xiaoguang huang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RecordAudio.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AMRFileCodec.h"

@implementation RecordAudio
@synthesize target;

- (void)dealloc {
    if (recorder) {
        [recorder stop];
        [recorder setDelegate:nil];
        recorder = nil;
    }

	recordedTmpFile = nil;
    if (avPlayer!=nil) {
        [avPlayer stop];
        avPlayer.delegate = nil;
        avPlayer = nil;
    }
}

-(id)init {
    self = [super init];
    if (self) {
        NSError * error;
        //Instanciate an instance of the AVAudioSession object.
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        //Setup the audioSession for playback and record. 
        //We could just use record and then switch it to playback leter, but
        //since we are going to do both lets set it up once.
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
								 sizeof (audioRouteOverride),
								 &audioRouteOverride);
        
        //Activate the session
        [audioSession setActive:YES error: &error];
    }
    return self;
}

- (NSURL *) stopRecord {
    NSURL *url = [[NSURL alloc]initWithString:recorder.url.absoluteString];
    if (recorder) {
        [recorder stop];
        [recorder setDelegate:nil];
        recorder = nil;
    }
    return url;
}

+(NSTimeInterval) getAudioTime:(NSData *) data {
    NSError * error;
    AVAudioPlayer*play = [[AVAudioPlayer alloc] initWithData:data error:&error];
    NSTimeInterval n = [play duration];
    return n;
}

//0 播放 1 播放完成 2出错
-(void)sendStatus:(int)status {
//    if (target.ins != nil ) {
//        [target.ins performSelector:target.act withObject:[NSNumber numberWithInt:status]];
//        //target.ins = nil;
//    }
    
    if (status!=0) {
        if (avPlayer!=nil) {
            [avPlayer stop];
            avPlayer.delegate = nil;
            avPlayer = nil;
        }
    }
}

-(void) stopPlay {
    if (avPlayer!=nil) {
        [avPlayer stop];
        avPlayer.delegate = nil;
        avPlayer = nil;
        [self sendStatus:1];
    }
}

-(NSData *)decodeAmr:(NSData *)data {
    if (!data) {
        return data;
    }
    return DecodeAMRToWAVE(data);
}

-(void) play:(NSData*) data
      target:(id)aTarget {
	//Setup the AVAudioPlayer to play the file that we just recorded.
    //在播放时，只停止
    if (avPlayer!=nil) {
        [self stopPlay];
        return;
    }
    NSError *error;
    NSData* o = [self decodeAmr:data];
    avPlayer = [[AVAudioPlayer alloc] initWithData:o error:&error];
    avPlayer.delegate = self;
    self.target = aTarget;
	[avPlayer prepareToPlay];
    [avPlayer setVolume:1.0];
	if(![avPlayer play]){
        [self sendStatus:1];
    } else {
        [self sendStatus:0];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self sendStatus:1];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    [self sendStatus:2];
}

-(void) startRecord {
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey, 
                                       //[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                       [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       //  [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       nil];
    
    //Now that we have our settings we are going to instanciate an instance of our recorder instance.
    //Generate a temp file for use by the recording.
    //This sample was one I found online and seems to be a good choice for making a tmp file that
    //will not overwrite an existing one.
    //I know this is a mess of collapsed things into 1 call.  I can break it out if need be.
    recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
    //NSLog(@"Using File called: %@",recordedTmpFile);

    NSError *error;
    //Setup the recorder to use this file and record to it.
    recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
    //Use the recorder to start the recording.
    //Im not sure why we set the delegate to self yet.  
    //Found this in antother example, but Im fuzzy on this still.
    [recorder setDelegate:self];
    //We call this to start the recording process and initialize 
    //the subsstems so that when we actually say "record" it starts right away.
    [recorder prepareToRecord];
    //Start the actual Recording
    [recorder record];
    //There is an optional method for doing the recording for a limited time see 
    //[recorder recordForDuration:(NSTimeInterval) 10]
}

@end

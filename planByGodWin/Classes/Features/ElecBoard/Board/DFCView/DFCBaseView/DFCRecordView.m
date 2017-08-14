//
//  DFCRecordView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRecordView.h"
#import "DFCBoardCareTaker.h"
#import "LWAudioRecorder.h"
#import "UIImage+MJ.h"
#import "DFCWaveView.h"
#import "DFCPlayControlView.h"

static CGFloat kTimeInterval = 0.1;
static NSString *const kAudioNameKey = @"kAudioNameKey";
static NSString *const kIsRecordKey = @"kIsRecordKey";


@interface DFCRecordView ()<LWAudioRecorderProtocol> {
    NSURL *_url;
    UILabel *_timeLabel;
    LWAudioRecordResult *_recordAudioRet;     //音频录制的缓存文件路径，用于上传
    CGFloat _currentTime;
    BOOL _loopable; // 标识是否需要循环播放
}

@property (strong, nonatomic)AVAudioPlayer *player;
@property (nonatomic, strong) DFCPlayControlView *playControlView;
@property (strong, nonatomic) NSTimer *myTimer;

@property (nonatomic, strong) UIImageView *recordView;
@property (nonatomic, strong) DFCWaveView *waveView;

@end

@implementation DFCRecordView

- (NSString *)resourcePath {
    return [_url path];
}

#pragma mark - lifecycle
- (void)removeRescourse {
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.name]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)closeMedia {
    if (_isRecord && [LWAudioRecorder sharedAudioRecorder].isRecording) {
        [self p_stopRecord];
    }else {
        [self.player pause];
        [self stopTimer];
        
        if (_isRecord ) {
            [[LWAudioRecorder sharedAudioRecorder] stopRecord];
        }
    }
}

- (void)dealloc {
    [self stopTimer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self p_initSubviews];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url {
    self = [super initWithFrame:frame];
    
    if (self) {
        NSString *pathExtension = [url pathExtension];
        NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] audioNewName];
        NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
        
        // 移动到资源文件夹
        NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, pathExtension]];
        self.filePath = path;   // 音频路径  add by gyh    
        NSURL *finalurl = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        if ([[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:url] toURL:finalurl error:&error] ) {
            DEBUG_NSLog(@"插入音频成功");
        } else {
            //NSLog(@"%@", error);
        }
        
        
        self.name = [NSString stringWithFormat:@"%@.%@", fileName, pathExtension];
        
        _url = finalurl;
        
        [self p_initSubviews];
    }
    
    return self;
}

- (void)removeFromSuperview {
    [self.playControlView removeFromSuperview];
    
    [super removeFromSuperview];
    
    [self stopTimer];
    [self closeMedia];
    
    _playControlView = nil;
    _player = nil;
    _currentTime = 0;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBool:_isRecord forKey:kIsRecordKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _isRecord = [aDecoder decodeBoolForKey:kIsRecordKey];
        if (self.name == nil) {
            self.name = [aDecoder decodeObjectForKey:kAudioNameKey];
        }
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        
        NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
        NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.name]];
        _url = [NSURL fileURLWithPath:path];
        
        self.filePath = path;
        
        [self p_initSubviews];
    }
    
    return self;
}

#pragma mark - actions
- (void)recordAction:(UIButton *)btn {
    if (btn.selected) {
        [self p_stopRecord];
    } else {
        if ([LWAudioRecorder sharedAudioRecorder].isRecording) {
            [[LWAudioRecorder sharedAudioRecorder] stopRecord];
        }
        
        [[LWAudioRecorder sharedAudioRecorder] startRecord];
        [LWAudioRecorder sharedAudioRecorder].recordDelegate = self;
    }
    btn.selected = !btn.selected;
}

- (void)startTimer {
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.myTimer
                                 forMode:NSDefaultRunLoopMode];
}

- (void)stopTimer {
    [self.myTimer invalidate];
    self.myTimer = nil;
}


- (DFCPlayControlView *)playControlView {
    if (!_playControlView) {
        _playControlView = [DFCPlayControlView playControlViewWithFrame:CGRectMake(0, 0, 500, 50) playControlType:kPlayControlTypeVoice];
        [_playControlView setTotalTime:[self p_howLongBefore:self.player.duration
                                                   bShowHour:NO]];
        [_playControlView setPlayTime:@"00:00"];
        
        // playAction
        @weakify(self)
        _playControlView.playBlock = ^(UIButton *btn) {
            @strongify(self)
            btn.selected = !btn.selected;
            if (btn.selected) {
                [self.player play];
                [self startTimer];
            } else {
                [self stopTimer];
                [self.player stop]; // 单次播放完成时，停止播放
            }
        };
        
        // playTimechangedAction
        _playControlView.playTimeChangedBlock = ^(UISlider *slider, CGFloat value) {
            @strongify(self)
            if ([self.player isPlaying]) {  // 如果正在播放
                _currentTime = self.player.duration * slider.value;
                [ self.player setCurrentTime:self.player.duration * slider.value];
                // 计时器停止
                [self.myTimer setFireDate:[NSDate distantFuture]];
            }
        };
        
        _playControlView.playTimeEndBlock = ^(UISlider *slider) {
            @strongify(self)
            
            _currentTime = self.player.duration * slider.value;
            self.player.currentTime = self.player.duration * slider.value;
            if ([self.player isPlaying]) {
                if ([self.player play]) {
                    [self.myTimer setFireDate:[NSDate distantPast]];
                }else {
                    DEBUG_NSLog(@"播放音频错误");
                }
            }
            [self updateTimeOnTimeLabel];
        };
        
        // fullscreenAction
        _playControlView.fullScreenBlock = ^(UIButton *btn) {
            @strongify(self)
            self->_loopable = !btn.selected;
            btn.selected = !btn.selected;
        };
    }
    return _playControlView;
}

- (void)updateTimeOnTimeLabel {
    [self.playControlView setPlayTime:[self p_howLongBefore:_currentTime
                                                  bShowHour:NO]];
    [self.playControlView setTotalTime:[self p_howLongBefore:self.player.duration
                                                   bShowHour:NO]];
}

- (void)refresh:(NSTimer *)timer {
    [_player updateMeters];
    
    // update time
    
    _currentTime += kTimeInterval;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playControlView setSliderValue:_currentTime * 1.0 / self.player.duration];
        [self.playControlView setPlayTime:[self p_howLongBefore:_currentTime
                                                      bShowHour:NO]];
        
    });
    
    if (_loopable) {   // 循环播放时，超出音频时间时，则置零
        if (_currentTime >= self.player.duration) {
            _currentTime = 0;
            [self.playControlView setSliderValue:0];
            [ self.player setCurrentTime:0];
            if (![self.player isPlaying]) {
                [self.player play];
            }
        }
    } else if (fabs(_currentTime - self.player.duration) < kTimeInterval) {
        self.playControlView.playButton.selected = NO;
        [self.playControlView setPlayTime:@"00:00"];
        [self.playControlView setSliderValue:0];
        [ self.player setCurrentTime:0];
        
        [self stopTimer];
        _currentTime = 0;
        [_player stop]; // 单次播放完成时，停止播放
    }
    
#if 0
    // 通知audioPlayer 说我们要去平均波形和最大波形
    float a = [audioPlayer averagePowerForChannel:0];
    float p = [audioPlayer peakPowerForChannel:0];
    a = (fabsf(a)+XMAX)/XMAX;
    p = (fabsf(p)+XMAX)/XMAX;
    [self.waveView addAveragePoint:a*50 andPeakPoint:p*50];
#else
    float aa = pow(10, (0.05 * [_player averagePowerForChannel:0]));
    float pp = pow(10, (0.05 * [_player peakPowerForChannel:0]));
    
    //NSLog(@"average is %f peak %f", [_player averagePowerForChannel:0], [_player averagePowerForChannel:0]);
    [self.waveView addAveragePoint:aa andPeakPoint:pp];
#endif
}

#pragma mark - private
- (NSString *)p_howLongBefore:(CGFloat)time bShowHour:(BOOL)bShowHour
{
    int deltaHour = time / 3600.0f;
    int deltaMinutes = (time - (deltaHour*3600))/ 60.0f;
    int deltaSeconds = round(time - (deltaHour * 3600) - (deltaMinutes*60.0f));
    
    if (bShowHour) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", deltaHour, deltaMinutes, deltaSeconds];
    } else{
        return [NSString stringWithFormat:@"%02d:%02d", deltaMinutes, deltaSeconds];
    }
}


- (void)setIsBackground:(BOOL)isBackground {
    [super setIsBackground:isBackground];
    [self removeGesture];
}

- (void)setCanEdit:(BOOL)canEdit {
    [super setCanEdit:canEdit];
    [self removeGesture];
}

- (void)setIsLocked:(BOOL)isLocked {
    [super setIsLocked:isLocked];
    [self removeGesture];
}

- (void)removeGesture {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]] ||
            [gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (void)p_initSubviews {
    [self removeGesture];
    
    [self DFC_setLayerCorner];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    if (_isRecord) {    //
        [self p_initRecordView];
    }else if (_url != nil) {
        self.isRecord = NO;
        [self p_initPlayView];
    } else {
        self.isRecord = YES;
        [self p_initRecordView];
    }
}

- (void)p_initRecordView {
    _recordView = [[UIImageView alloc] initWithFrame:self.bounds];
    _recordView.userInteractionEnabled = YES;
    _recordView.image = [UIImage imageNamed:@"Board_Record_Background"];
    [self addSubview:_recordView];
    
    // 时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(460 - 60, 0, 50, 50)];
    
    _timeLabel.text = @"00:00";
    _timeLabel.font = [UIFont systemFontOfSize:14];
    
    [self.recordView addSubview:_timeLabel];
    
    [_timeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.recordView.right).offset(-20);
        make.top.equalTo(self.recordView.top);
        make.bottom.equalTo(self.recordView.bottom);
        make.width.equalTo(50);
    }];
    
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //recordButton.frame = CGRectMake(15, 8, 34, 34);
    [recordButton setImage:[UIImage imageNamed:@"Board_Start_Record"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage imageNamed:@"Board_Stop_Record"] forState:UIControlStateSelected];
    recordButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    //[recordButton setTitle:@"录音" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.recordView addSubview:recordButton];
    
    [recordButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recordView.left).offset(15);
        //make.centerY.equalTo(self.recordView.centerY);
        make.top.equalTo(self.recordView.top).offset(5);
        make.bottom.equalTo(self.recordView.bottom).offset(-5);
        make.width.equalTo(recordButton.height);
    }];
}

- (void)p_stopRecord {
    if (![LWAudioRecorder sharedAudioRecorder].isRecording) {
        return;
    }
    LWAudioRecordResult *result = [[LWAudioRecorder sharedAudioRecorder] stopRecord];
    //result.recordTime > 60
    if (0 == result.recordTime || nil == result.recordedAmrFileUrl.absoluteString) {
        return;
    }
    
    _recordAudioRet = result;
    
    // 移动音频
    //NSLog(@"uuuuu%@", _recordAudioRet.recordedFileUrl);
    //NSURL *audioUrl = _recordAudioRet.recordedAmrFileUrl;
    NSString *audioUrlStr = _recordAudioRet.recordedFileUrl.absoluteString;
    NSURL *audioUrl = [NSURL fileURLWithPath:audioUrlStr];
    NSString *pathExtension = [audioUrl pathExtension];
    NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] audioNewName];
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    
    // 移动到资源文件夹
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, pathExtension]];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.filePath = path;
    NSError *error = nil;
    if ([[NSFileManager defaultManager] moveItemAtURL:audioUrl toURL:url error:&error] ) {
        DEBUG_NSLog(@"录制成功");
            //  开启音频录制

        

    } else {
        //NSLog(@"%@", error);
    }
    _isRecord = NO;
    _url = url;
    self.name = [NSString stringWithFormat:@"%@.%@", fileName, pathExtension];
    
    [self.recordView removeFromSuperview];
    [self p_initSubviews];
}

- (void)p_initPlayView {
//    _recordView = [[UIImageView alloc] initWithFrame:self.bounds];
//    _recordView.userInteractionEnabled = YES;
//    _recordView.image = [UIImage imageNamed:@"Board_Record_Background"];
//    [self addSubview:_recordView];
    [self.playControlView setTotalTime:[self p_howLongBefore:self.player.duration
                                                   bShowHour:NO]];
    
    self.waveView = [[DFCWaveView alloc] initWithFrame:self.bounds];
    [self addSubview:self.waveView];
}

-(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);//size为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark - getter
- (AVAudioPlayer *)player {
    if (!_player) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_url error:nil];
        [_player prepareToPlay];
        [_player setMeteringEnabled:YES];
    }
    
    return _player;
}

- (void)createGesture {
    // 创建轻拍手势
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)singleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self addPlayControlView];
        self.playControlView.hidden = !self.playControlView.hidden;
    }
}

- (void)showPlayControl:(BOOL)showPlayControl {
    [self setNeedsLayout];
    self.playControlView.hidden = !showPlayControl;
}

#pragma mark - recordDelegate
- (void)audioRecorderTrackTime:(CGFloat)time{
    DEBUG_NSLog(@"timer=%f",time);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _timeLabel.text = [self p_howLongBefore:time
                                      bShowHour:NO];
    });
}

- (void)addPlayControlView {
    if (self.playControlView.superview == nil) {
        if (self.superview) {
            if (_url) {
                [self.superview addSubview:self.playControlView];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self addPlayControlView];
    _playControlView.hidden = _isRecord;
    
    self.playControlView.center = CGPointMake(self.center.x, CGRectGetMaxY(self.frame) + self.bounds.size.height / 2);
    [self createGesture];
}

- (void)layoutControlView {
    self.playControlView.center = CGPointMake(self.center.x, CGRectGetMaxY(self.frame) + self.bounds.size.height / 2);
}

@end

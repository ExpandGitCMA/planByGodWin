//
//  DFCVideoView.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/14.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//
#import "DFCVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
#import "DFCBoardCareTaker.h"
#import "DFCPlayControlView.h"

//Resources.bundle
#define SELFWIDTH self.bounds.size.width
#define SELFHEIGHT self.bounds.size.height

#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height

static NSString *const kVideoNameKey = @"kVideoNameKey";

//视频播放状态记录
typedef NS_ENUM(NSInteger, VideoPlayerState) {
    VideoPlayerStatePlay,
    VideoPlayerStatePause,
    VideoPlayerStateStop
};

@interface DFCVideoView () {
    NSURL *_url;
    BOOL _canEdit;
    
    CGFloat _currentTime;
    
    BOOL _shouldNotDeletePlayControlView;
}

@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;


@property (nonatomic, strong) DFCPlayControlView *playControlView;

@property (nonatomic, assign) CGRect tempFrame;
@property (nonatomic, strong) UIView *superView;


@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL isCallBack;
@property (assign, nonatomic) VideoPlayerState currentVideoPlayerState;

@end

#pragma mark - implementation
#pragma mark -
@implementation DFCVideoView

- (NSString *)resourcePath {
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.name]];
    return path;
}

#pragma mark - 对外提供的方法
- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString *)name {
    self = [super initWithFrame:frame];
    
    if (self) {
        // 根据名字获得资源url
        self.name = name;
        
        [self loadVideo];
        
        [self setName:name];
    }
    
    return self;
}

- (void)p_initPlayer {
    _playerItem = [AVPlayerItem playerItemWithURL:_url];
    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [self.layer insertSublayer:_playerLayer atIndex:0];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        
        // 兼容
        if (self.name == nil) {
            self.name = [aDecoder decodeObjectForKey:kVideoNameKey];
        }
        
        [self loadVideo];
    }
    return self;
}

- (void)loadVideo {
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.name]];
    _url = [NSURL fileURLWithPath:path];
    self.filePath = path;
    
    self.userInteractionEnabled = YES;
    self.size = self.bounds.size;
    
    _player = nil;
    
    [self p_initPlayer];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}

- (void)startTimer {
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1f
                                                  target:self
                                                selector:@selector(timeAction:)
                                                userInfo:nil
                                                 repeats:YES];
    //[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timeAction:(NSTimer *)timer {
    [self updateTimeOnTimeLabel];
    [self updateTimeOnProgress];
}

- (void)stopTimer {
    [self.timer invalidate];
    _timer = nil;
}

- (void)setName:(NSString *)name {
    [super setName:name];
    [self loadVideo];
}

- (NSString *)stringWithTime:(NSTimeInterval)time {
    NSInteger dMin = time / 60;
    NSInteger dSec = (NSInteger)time % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", dMin, dSec];
}

- (void)play {
    [self startTimer];
    self.currentVideoPlayerState = VideoPlayerStatePlay;
    [self.player play];
}

- (void)pause {
    [self stopTimer];
    self.currentVideoPlayerState = VideoPlayerStatePause;
    [self.player pause];
}

- (void)closeMedia {
    [self pause];
}

- (CGSize)getScreenSize {
    CGSize size = CGSizeZero;
    AVAsset *asset = [AVAsset assetWithURL:_url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        size.width = videoTrack.naturalSize.width;
        size.height = videoTrack.naturalSize.height;
    }
    return size;
}

- (UIImage *)getScreenThumbImage {
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:_url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    
    NSError *error = nil;
    CMTime time = self.player.currentItem.currentTime;
    CMTime actucalTime; //缩略图实际生成的时间
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time
                                                actualTime:&actucalTime
                                                     error:&error];
    if (error) {
        DEBUG_NSLog(@"截取视频图片失败:%@",error.localizedDescription);
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.image = image;
    
    return image;
}

- (NSString *)getTotalTime {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:_url options:opts];
    return [self stringWithTime:(urlAsset.duration.value / urlAsset.duration.timescale)];
}

#pragma mark - layoutSubviews初始化所用控件
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor blackColor];
    
    if (!self.isFullScreen) {
        self.tempFrame = self.frame;
        self.superView = self.superview;
    }
    
    if (self.playControlView.superview == nil) {
        if (self.superview) {
            [self.superview addSubview:self.playControlView];
        }
    }
    
    self.playControlView.frame = CGRectMake(0, 0, 500, 50);
    if (self.isFullScreen) {
        self.playControlView.center = CGPointMake(self.center.x, CGRectGetMaxY(self.frame) - 50);
    } else {
        self.playControlView.center = CGPointMake(self.center.x, CGRectGetMaxY(self.frame));
    }
    
    self.playerLayer.frame = self.bounds;
    
    [self createGesture];
}

- (void)layoutControlView {
    self.playControlView.frame = CGRectMake(0, 0, 500, 50);
    if (self.isFullScreen) {
        self.playControlView.center = CGPointMake(self.center.x, CGRectGetMaxY(self.frame) - 50);
    } else {
        self.playControlView.center = CGPointMake(self.center.x, CGRectGetMaxY(self.frame));
    }
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    [super pinchView:pinchGestureRecognizer];
    
    self.tempFrame = self.frame;
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    [super panView:panGestureRecognizer];
    
    self.tempFrame = self.frame;
}

- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer {
    [super rotateView:rotationGestureRecognizer];
    
    self.tempFrame = self.frame;
}

#pragma mark - 手势方法
// 创建手势
- (void)createGesture {
    // 创建轻拍手势
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)addNotification {
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterPlayGround)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

#pragma mark - 屏幕旋转相关
- (void)changeSmallScreen {
    self.isFullScreen = NO;
    [self removeSelfFromSupview];
    [self.superView addSubview:self];
    self.frame = self.tempFrame;
    self.transform = CGAffineTransformRotate(self.transform, self.rotation);
    
    [self setCanEdit:_canEdit];
    
    [self.playControlView removeFromSuperview];
    [self.superview addSubview:self.playControlView];
    [self setNeedsLayout];
}

- (void)removeSelfFromSupview {
    _shouldNotDeletePlayControlView = YES;
    [self removeFromSuperview];
    _shouldNotDeletePlayControlView = NO;
}

- (void)removeFromSuperview {
    if (!_shouldNotDeletePlayControlView) {
        [self.playControlView removeFromSuperview];
        _playControlView = nil;
    }
    
    [super removeFromSuperview];
}

- (void)stopFullScreenPlay {
    if (self.isFullScreen) {
        [self closeMedia];
        [self changeSmallScreen];
        self.playControlView.playButton.selected = NO;
    }
}

- (void)changeSelfFrame2FullScreen {
    self.bounds = CGRectMake(0, 0, SCREENW, SCREENH);
    self.center = CGPointMake(SCREENW / 2, SCREENH / 2);
    self.playerLayer.bounds = CGRectMake(0, 0, SCREENW, SCREENH);
    self.playerLayer.position = CGPointMake(SCREENW / 2, SCREENH / 2);
    self.isFullScreen = YES;
    [self removeSelfFromSupview];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.transform = CGAffineTransformRotate(self.transform, -self.rotation);
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    
    _canEdit = self.canEdit;
    [self setCanEdit:YES];
    
    
    [self.playControlView removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self.playControlView];
    [self setNeedsLayout];
}

#pragma mark - NSNotification
- (void)appDidEnterBackground {
    [self pause];
    self.isCallBack = YES;
}

- (void)appDidEnterPlayGround {
    if (self.isCallBack) {
        if (self.currentVideoPlayerState == VideoPlayerStatePlay) {
            [self play];
            self.isCallBack = NO;
        }
    }
}

- (void)singleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"%@", self.playControlView.superview);
        if (self.playControlView.superview == nil) {
            if (self.superview) {
                [self.superview addSubview:self.playControlView];
            }
        }
        
        self.playControlView.hidden = !self.playControlView.hidden;
    }
}

- (void)showPlayControl:(BOOL)showPlayControl {
    [self setNeedsLayout];
    self.playControlView.hidden = !showPlayControl;
}

- (DFCPlayControlView *)playControlView {
    if (!_playControlView) {
        _playControlView = [DFCPlayControlView playControlViewWithFrame:CGRectMake(0, 0, 500, 50) playControlType:kPlayControlTypeVideo];
        [_playControlView setTotalTime:[self getTotalTime]];
        
        // playAction
        @weakify(self)
        _playControlView.playBlock = ^(UIButton *btn) {
            @strongify(self)
            btn.selected = !btn.selected;
            if (btn.selected) {
                [self play];
            } else {
                [self pause];
            }
        };
        
        // playTimechangedAction
        _playControlView.playTimeChangedBlock = ^(UISlider *slider, CGFloat value) {
            @strongify(self)
            NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * value;
            // 设置当前播放时间
            [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            
            [self updateTimeOnTimeLabel];
        };
        
        // fullscreenAction
        _playControlView.fullScreenBlock = ^(UIButton *btn) {
            @strongify(self)
            btn.selected = !btn.selected;
            if (btn.selected) {
                [self changeSelfFrame2FullScreen];
            } else {
                [self changeSmallScreen];
            }
        };
    }
    return _playControlView;
}

- (void)updateTimeOnTimeLabel {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    [self.playControlView setPlayTime:[self stringWithTime:currentTime]];
    NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
    [self.playControlView setTotalTime:[self stringWithTime:duration]];
}

- (void)updateTimeOnProgress {
    [self.playControlView setSliderValue:CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration)];
    
    if (fabs(CMTimeGetSeconds(self.player.currentTime) - CMTimeGetSeconds(self.player.currentItem.duration)) <= 0.1) {
        [self stopTimer];
        
        self.playControlView.playButton.selected = NO;
        
        [self.playControlView setPlayTime:@"00:00"];
        [self.playControlView setSliderValue:0];
        
        [self.player pause];
        [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

@end

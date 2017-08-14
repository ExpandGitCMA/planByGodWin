//
//  DFCRecordScreenView.m
//  planByGodWin
//
//  Created by dfc on 2017/3/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRecordScreenView.h"
#import <ImageIO/ImageIO.h>

@interface DFCRecordScreenView ()
{
    NSInteger _totalCount;
}
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIImageView *recordingImageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *liveButton;

@property (nonatomic,strong) NSMutableArray *frames;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation DFCRecordScreenView

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCount) userInfo:nil repeats:YES];
//        _timer.fireDate = [NSDate distantFuture];   // 暂停
    }
    return _timer;
}

- (NSMutableArray *)frames{
    if (!_frames) {
        _frames = [NSMutableArray array];
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"Recording" withExtension:@"gif"];
        CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
        size_t frameCout = CGImageSourceGetCount(gifSource);
        
        for (size_t i = 0; i<frameCout; i++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            [_frames addObject:image];
            CGImageRelease(imageRef);
        }
    }
    return _frames;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _recordBtn.adjustsImageWhenHighlighted = NO;
    _liveButton.adjustsImageWhenHighlighted = NO;
    
    _totalCount = 0;
    
    self.timer.fireDate = [NSDate distantFuture];   // 暂停
}

//- (void)stopRecord{ // 结束
//    if (self.delegate && [self.delegate respondsToSelector:@selector(stopRecordScreen:)]) {
//        [self.delegate stopRecordScreen:nil];
//    }
//}

// 计时器记录录屏时间
- (void)timeCount{
    _totalCount++;
    
    _durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",_totalCount/3600,_totalCount % 3600 / 60,_totalCount%60];
}

- (void)stopViewAnimating{
    // 显示按钮
    self.timer.fireDate = [NSDate distantFuture];   // 暂停
    // 总长度显示置零
    _durationLabel.text = @"00:00:00";
    _totalCount = 0;
    
}

- (void)beginViewAnimating{
//    _recordBtn.hidden = YES;
//    _recordingImageView.hidden = NO;
//    [_recordingImageView startAnimating];
    
    self.timer.fireDate = [NSDate date];   // 开始
}

+ (DFCRecordScreenView *)recordScreenView{
    return [[NSBundle mainBundle]loadNibNamed:@"DFCRecordScreenView" owner:nil options:nil].firstObject;
}


- (IBAction)adjustToViewToolBar:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(setToolBarHidden:)]) {
        [self.delegate setToolBarHidden:sender.selected];
    }
}

- (void)setIsRecording:(BOOL)isRecording{
    _isRecording = isRecording;
    _recordBtn.selected = _isRecording;
}

- (IBAction)recordScreen:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(startRecordScreen:)]) {
            [self.delegate startRecordScreen:sender];
        }
    }else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(stopRecordScreen:)]) {
            [self.delegate stopRecordScreen:nil];
        }
    }
}
// 直播按钮
- (IBAction)startLive:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlToLive:)]) {
        [self.delegate controlToLive:sender];
    }
}

- (void)setIsBroadcasting:(BOOL)isBroadcasting{
    _isBroadcasting = isBroadcasting;
    _liveButton.selected = _isBroadcasting;
}

- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

@end

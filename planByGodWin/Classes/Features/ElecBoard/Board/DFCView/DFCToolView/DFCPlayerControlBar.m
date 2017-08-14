//
//  DFCPlayerControlBar.m
//  planByGodWin
//
//  Created by dfc on 2017/3/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPlayerControlBar.h"
#import "UIImage+MJ.h"


@interface DFCPlayerControlBar()<DFCVolumnCtrlViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playBtn; // 播放控制
@property (weak, nonatomic) IBOutlet UIButton *volunmBtn;   // 音量控制
@property (weak, nonatomic) IBOutlet UILabel *processLabel;     // 当前进度
@property (weak, nonatomic) IBOutlet UISlider *processSlider;   // 进度条
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;    // 总时长
@property (weak, nonatomic) IBOutlet UIButton *cycleBtn;   // 循环播放按钮



@end

@implementation DFCPlayerControlBar

- (void)setCanDelete:(BOOL)canDelete{
}
- (void)setCanTaped:(BOOL)canTapped{
}
- (void)setCanEdit:(BOOL)canEdit{
}

- (DFCVolumnCtrlView *)volumnControlView{
    if (!_volumnControlView) {
        _volumnControlView = [DFCVolumnCtrlView volumnControlView];
        _volumnControlView.delegate = self;
    }
    return _volumnControlView;
}

// DFCVolumnCtrlViewDelegate    触发该类的改变音量方法
- (void)controlVolumn:(UISlider *)slider{
    if (self.controlBarDelegate && [self.controlBarDelegate respondsToSelector:@selector(playerControlBar:didChangeVolumnButton:)]) {
        [self.controlBarDelegate playerControlBar:self didChangeVolumnButton:slider];
    }
}

+ (DFCPlayerControlBar *)playerControlBar{
    
    DFCPlayerControlBar *bar = [[NSBundle mainBundle]loadNibNamed:@"DFCPlayerControlBar" owner:nil options:nil].firstObject;
    
    return bar;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
//    // 设置进度条
    _processSlider.minimumTrackTintColor = kUIColorFromRGB(0x4da961);
    _processSlider.maximumTrackTintColor = kUIColorFromRGB(0xc9c9c9);
    _processSlider.thumbTintColor = kUIColorFromRGB(0x4cc366);
    
    // 设置圆角
    self.layer.cornerRadius = 3.0;
    
    // 添加音量控制视图
    [self addSubview:self.volumnControlView];
    self.volumnControlView.frame = CGRectMake(40, 50, 200, 40);
    
    // 默认隐藏
    self.volumnControlView.hidden = YES;
}

- (void)setIsSelectVolumn:(BOOL)isSelectVolumn{
    _isSelectVolumn = isSelectVolumn;
    self.volumnControlView.hidden = !_isSelectVolumn;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 设置进度条
        _processSlider.minimumTrackTintColor = kUIColorFromRGB(0x4da961);
        _processSlider.maximumTrackTintColor = kUIColorFromRGB(0xc9c9c9);
        _processSlider.thumbTintColor = kUIColorFromRGB(0x4cc366);
        
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (!self.clipsToBounds && !self.hidden && self.alpha>0) {
        UIView *result = [super hitTest:point withEvent:event];
        if (result) {
            return result;
        }else {
            for (UIView *subView in self.subviews.reverseObjectEnumerator) {
                CGPoint subPoint = [subView convertPoint:point fromView:self];
                result = [subView hitTest:subPoint withEvent:event];
                if (result) {
                    return result;
                }
            }
        }
    }
    
    return nil;
}


- (void)setCurrentVolumn:(CGFloat)currentVolumn{
    _currentVolumn = currentVolumn;
    
    self.volumnControlView.currentVolumn = _currentVolumn;
}

- (void)setProcessPercent:(CGFloat)processPercent{
    _processPercent = processPercent;
    _processSlider.value = _processPercent;
}

- (void)setDurationString:(NSString *)durationString{
    _durationString = durationString;
    _durationLabel.text = _durationString;
}

- (void)setCurrentProcessString:(NSString *)currentProcessString{
    _currentProcessString = currentProcessString;
    _processLabel.text = _currentProcessString;
}

- (void)setIsStop:(BOOL)isStop{
    _isStop = isStop;
    _playBtn.selected = !_isStop;
}

- (IBAction)clickPlayBtn:(UIButton *)sender {
    if (self.controlBarDelegate && [self.controlBarDelegate respondsToSelector:@selector(playerControlBar:didClickPlayButton:)]) {
        [self.controlBarDelegate playerControlBar:self didClickPlayButton:sender];
    }
}

- (IBAction)clickVolumnbtn:(UIButton *)sender {
    if (self.controlBarDelegate && [self.controlBarDelegate respondsToSelector:@selector(playerControlBar:didClickVolumnButton:)]) {
        [self.controlBarDelegate playerControlBar:self didClickVolumnButton:sender];
    }
}

- (IBAction)changeVolumn:(UISlider *)sender {
    if (self.controlBarDelegate && [self.controlBarDelegate respondsToSelector:@selector(playerControlBar:didChangeCurrentProcessWithSlider:)]) {
        [self.controlBarDelegate playerControlBar:self didChangeCurrentProcessWithSlider:sender];
    }
}

- (IBAction)clickCyclePlayBtn:(UIButton *)sender {
    if (self.controlBarDelegate && [self.controlBarDelegate respondsToSelector:@selector(playerControlBar:didClickCyclePlayButton:)]) {
        [self.controlBarDelegate playerControlBar:self didClickCyclePlayButton:sender];
    }
}

@end

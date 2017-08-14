//
//  DFCPlayControlView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPlayControlView.h"
#import "UIImage+MJ.h"

@interface DFCPlayControlView ()

@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@end

@implementation DFCPlayControlView

+ (instancetype)playControlViewWithFrame:(CGRect)frame
                         playControlType:(kPlayControlType)type {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DFCPlayControlView class]) owner:self options:nil];
    DFCPlayControlView *controlView = [arr firstObject];
    controlView.frame = frame;
    controlView.type = type;
    [controlView DFC_setLayerCorner];
    controlView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    return controlView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.playSlider addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
}

- (void)setType:(kPlayControlType)type {
    _type = type;
    
    switch (_type) {
        case kPlayControlTypeVideo: {
            break;
        }
        case kPlayControlTypeVoice: {
            [self.fullScreenButton setImage:[UIImage imageNamed:@"Board_Recycle_N"] forState:UIControlStateNormal];
            [self.fullScreenButton setImage:[UIImage imageNamed:@"Board_Recycle_Y"] forState:UIControlStateSelected];
            [self.fullScreenButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [self.fullScreenButton setBackgroundImage:[UIImage imageWithColor:kUIColorFromRGB(0x4cc366)] forState:UIControlStateSelected];
            break;
        }
        default:
            break;
    }
}

- (IBAction)playTimeValueChanged:(id)sender {
    if (self.playTimeChangedBlock) {
        self.playTimeChangedBlock(sender, ((UISlider *)sender).value);
    }
}

- (void)touchDown:(UISlider *)slider {
    if (self.playTimeEndBlock) {
        self.playTimeEndBlock(slider);
    }
}

- (void)setSliderValue:(CGFloat)value {
    self.playSlider.value = value;
}

- (void)setPlayTime:(NSString *)playTime {
    self.playTimeLabel.text = playTime;
}

- (void)setTotalTime:(NSString *)totalTime {
    self.totalTimeLabel.text = totalTime;
}

- (IBAction)fullScreen:(id)sender {
    if (self.fullScreenBlock) {
        self.fullScreenBlock(sender);
    }
}

- (IBAction)playAction:(id)sender {
    if (self.playBlock) {
        self.playBlock(sender);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

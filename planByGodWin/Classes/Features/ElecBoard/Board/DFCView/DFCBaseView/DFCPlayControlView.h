//
//  DFCPlayControlView.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^kPlayBlock)(UIButton *btn);
typedef void(^kPlayTimeChangedBlock)(UISlider *slider, CGFloat value);
typedef void(^kPlayTimeEndBlock)(UISlider *slider);
typedef void(^kFullScreenBlock)(UIButton *btn);

typedef NS_ENUM(NSUInteger, kPlayControlType) {
    kPlayControlTypeVideo,
    kPlayControlTypeVoice,
};

@interface DFCPlayControlView : UIView

+ (instancetype)playControlViewWithFrame:(CGRect)frame
                         playControlType:(kPlayControlType)type;

@property (nonatomic, copy) kPlayBlock playBlock;
@property (nonatomic, copy) kPlayTimeChangedBlock playTimeChangedBlock;
@property (nonatomic, copy) kPlayTimeEndBlock playTimeEndBlock;
@property (nonatomic, copy) kFullScreenBlock fullScreenBlock;

@property (nonatomic, assign) kPlayControlType type;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

- (void)setSliderValue:(CGFloat)value;
- (void)setPlayTime:(NSString *)playTime;
- (void)setTotalTime:(NSString *)totalTime;

@end

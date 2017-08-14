//
//  DFCPlayerControlBar.h
//  planByGodWin
//
//  Created by dfc on 2017/3/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCBaseView.h"
#import "DFCVolumnCtrlView.h"

// 播放器播放控制条,可用于音频、视频播放器的控制条
@class DFCPlayerControlBar;
@protocol DFCPlayerControlBarDelegate <NSObject>

/*点击播放按钮*/
- (void)playerControlBar:(DFCPlayerControlBar *)controlBar didClickPlayButton:(UIButton *)playBtn;

/*点击音量按钮*/
- (void)playerControlBar:(DFCPlayerControlBar *)controlBar didClickVolumnButton:(UIButton *)volumnBtn;

/*改变音量*/
- (void)playerControlBar:(DFCPlayerControlBar *)controlBar didChangeVolumnButton:(UISlider *)volumnSlider;

/*改变当前进度*/
- (void)playerControlBar:(DFCPlayerControlBar *)controlBar didChangeCurrentProcessWithSlider:(UISlider *)slider;

/*点击循环播放按钮*/
- (void)playerControlBar:(DFCPlayerControlBar *)controlBar didClickCyclePlayButton:(UIButton *)cyclePlayBtn;

@end

@interface DFCPlayerControlBar : UIView

@property (nonatomic,weak) id <DFCPlayerControlBarDelegate> controlBarDelegate;
@property (strong,nonatomic) DFCVolumnCtrlView *volumnControlView;

// 播放进度
@property (nonatomic,assign) CGFloat processPercent;
// 当前音量
@property (nonatomic,assign) CGFloat currentVolumn;

@property (nonatomic,copy) NSString *currentProcessString;
@property (nonatomic,copy) NSString *durationString;

@property (nonatomic,assign) BOOL isStop;
@property (nonatomic,assign) BOOL isSelectVolumn;


+ (DFCPlayerControlBar *)playerControlBar;


/**以下属性、方法为了响应对画板进行操作，在此类中不做任何操作**/
- (void)setCanDelete:(BOOL)canDelete;
- (void)setCanTaped:(BOOL)canTapped;
- (void)setCanEdit:(BOOL)canEdit;
@property (nonatomic,assign) BOOL isSelected;


@end

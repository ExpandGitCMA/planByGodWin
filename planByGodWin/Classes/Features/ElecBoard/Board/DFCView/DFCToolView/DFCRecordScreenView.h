//
//  DFCRecordScreenView.h
//  planByGodWin
//
//  Created by dfc on 2017/3/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  DFCRecordScreenViewDelegate <NSObject>
// 开始录屏
- (void)startRecordScreen:(UIButton *)sender;
// 停止录屏
- (void)stopRecordScreen:(UIButton *)sender;

// 根据选择来显示或隐藏工具条
- (void)setToolBarHidden:(BOOL)isHidden;

// 控制直播
- (void)controlToLive:(UIButton *)sender;
@end

@interface DFCRecordScreenView : UIView

@property (nonatomic,weak) id<DFCRecordScreenViewDelegate> delegate;
@property (nonatomic,assign) BOOL isBroadcasting;   // 标识是否在直播
@property (nonatomic,assign) BOOL isRecording;  // 标识是否在录屏

+ (DFCRecordScreenView *)recordScreenView;

- (void)stopViewAnimating;
- (void)beginViewAnimating;

@end

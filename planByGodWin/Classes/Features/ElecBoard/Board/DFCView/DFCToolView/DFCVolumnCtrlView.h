//
//  DFCVolumnCtrlView.h
//  planByGodWin
//
//  Created by dfc on 2017/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  DFCVolumnCtrlViewDelegate <NSObject>

- (void)controlVolumn:(UISlider *)slider;

@end

@interface DFCVolumnCtrlView : UIView

@property (nonatomic,weak) id <DFCVolumnCtrlViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISlider *volumnSlider;
@property (nonatomic,assign) CGFloat currentVolumn;

+ (DFCVolumnCtrlView *)volumnControlView;

@end

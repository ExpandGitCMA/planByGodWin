//
//  DFCVolumnCtrlView.m
//  planByGodWin
//
//  Created by dfc on 2017/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCVolumnCtrlView.h"

@interface DFCVolumnCtrlView ()


@end

@implementation DFCVolumnCtrlView

+ (DFCVolumnCtrlView *)volumnControlView{
    return [[NSBundle mainBundle]loadNibNamed:@"DFCVolumnCtrlView" owner:nil options:nil].firstObject;
}

- (IBAction)changeVolumn:(UISlider *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlVolumn:)]) {
        [self.delegate controlVolumn:sender];
    }
}

- (void)awakeFromNib{
    [super awakeFromNib];
    // 设置进度条
    _volumnSlider.minimumTrackTintColor = kUIColorFromRGB(0x4da961);
    _volumnSlider.maximumTrackTintColor = kUIColorFromRGB(0xc9c9c9);
    _volumnSlider.thumbTintColor = kUIColorFromRGB(0x4cc366);
    
}

- (void)setCurrentVolumn:(CGFloat)currentVolumn{
    _currentVolumn = currentVolumn;
    _volumnSlider.value = _currentVolumn;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    UIView *view = [super hitTest:point withEvent:event];
//    if (view == nil) {
//        for (UIView *subView in self.subviews) {
//            
//            CGPoint p = [subView convertPoint:point fromView:self];
//            if (CGRectContainsPoint(subView.frame, p)) {
//                view = subView;
//            }
//        }
//    }
//    return view;
//}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    if (CGRectContainsPoint(_volumnSlider.frame, point)) {
//        return YES;
//    }
//    return NO;
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

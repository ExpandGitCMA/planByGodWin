//
//  DFCSliderView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSliderView.h"

@interface DFCSliderView ()

@property (weak, nonatomic) IBOutlet UISlider *sliderView;

@end

@implementation DFCSliderView

+ (DFCSliderView *)sliderViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCSliderView" owner:self options:nil];
    DFCSliderView *sliderView = [arr firstObject];
    sliderView.value = 0.2;
    return sliderView;
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _value = slider.value;
    if ([self.delegate respondsToSelector:@selector(sliderView:didValueChanged:)]) {
        [self.delegate sliderView:slider didValueChanged:slider.value];
    }
}

- (CGFloat)value {
    return _value;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.sliderView DFC_setSelectValueStyle];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

//
//  ColorView.m
//  planByGodWin
//
//  Created by DaFenQi on 16/10/20.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "ColorView.h"
#import "IMColor.h"
#import "DFCPickColorView.h"

#define kBaseTag 11

#define kColorViewSize CGSizeMake(438, 155)

@interface ColorView () <PickColorViewDelegate> {
    //NSArray *_colors;
}

@property (weak, nonatomic) IBOutlet DFCPickColorView *pickColorView;
@property (weak, nonatomic) IBOutlet UIButton *showSelectColorButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *blackButton;
@property (weak, nonatomic) IBOutlet UIButton *blueButton;

@end

@implementation ColorView
/*
 F15556 ffa036 ffd736 45eb6f 258ae6 9A3CD2 fdc1a5 895437 25262a a3a5aa e3dede
 */

- (void)pickColorView:(DFCPickColorView *)pickColorView didSelectColor:(UIColor *)color {
    //[self.showSelectColorButton setBackgroundImage:nil forState:UIControlStateNormal];
    self.showSelectColorButton.backgroundColor = color;
    self.selectColor = color;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    
    self.showSelectColorButton.selected = YES;
    
    [self.delegate colorView:self didSelectColor:color];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _pickColorView.delegate = self;
    _pickColorView.image = [UIImage imageNamed:@"ElecBoard_ColorPan"];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view DFC_setLayerCorner];
        }
    }

    [self DFC_setLayerCorner];
    //self.redButton.selected = YES;
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    //_colors = @[ @"#F15556", @"#ffa036", @"#ffd736", @"#45eb6f", @"#258ae6", @"#9A3CD2", @"#fdc1a5", @"#895437", @"#25262a", @"#a3a5aa", @"#e3dede", @"#e3dede"];
}

+ (ColorView *)colorViewWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = (CGRect){CGPointZero, kColorViewSize};
    }
    
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"ColorView" owner:self options:nil];
    ColorView *colorView = [arr firstObject];
    //colorView.backgroundColor = kUIColorFromRGB(0xf3f3f3);
    return colorView;
}

- (IBAction)colorAction:(UIButton *)sender {
//    NSString *colorStr = _colors[sender.tag - kBaseTag];
//    UIColor *color = [UIColor colorWithHex:colorStr alpha:1.0f];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    
    sender.selected = YES;
    
    UIColor *color = sender.backgroundColor;
    self.selectColor = color;
    [self.delegate colorView:self didSelectColor:color];
}

- (void)selectBlack {
    self.blackButton.selected = YES;
}

- (void)selectRed {
    self.redButton.selected = YES;
}

- (void)selectBlue {
    self.blueButton.selected = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

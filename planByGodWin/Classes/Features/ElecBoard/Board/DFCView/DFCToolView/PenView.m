//
//  PenView.m
//  planByGodWin
//
//  Created by DaFenQi on 16/10/20.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "PenView.h"
#import "WritingBrush.h"
#import "SmoothBrush.h"

#define kPencilViewSize CGSizeMake(160, 110)

@interface PenView ()

@property (weak, nonatomic) IBOutlet UISlider *widthSlider;
@property (weak, nonatomic) IBOutlet UIButton *markButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation PenView

- (IBAction)maobiAction:(id)sender {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    ((UIButton *)sender).selected = YES;
    
    self.selectBrush = [WritingBrush new];
    [self.delegate penViewDidSelectMaobi];
}

- (IBAction)markAction:(id)sender {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    ((UIButton *)sender).selected = YES;

    self.selectBrush = [SmoothBrush new];
    [self.delegate penViewDidSelectMarkPen];
}

+ (PenView *)penViewWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = (CGRect){CGPointZero, kPencilViewSize};
    }
    
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"PenView" owner:self options:nil];
    PenView *penView = [arr firstObject];
    //penView.backgroundColor = kUIColorFromRGB(0xf3f3f3);
    return penView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.widthSlider DFC_setSelectValueStyle];

    self.markButton.selected = YES;
    
    UIImage *image = [UIImage imageNamed:@"Board_Pen_Background"];
    self.backgroundImageView.alpha = .8f;
    self.backgroundImageView.image = [image stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (IBAction)strokeWidthChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self.delegate penViewWidthSlider:slider didValueChanged:slider.value];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

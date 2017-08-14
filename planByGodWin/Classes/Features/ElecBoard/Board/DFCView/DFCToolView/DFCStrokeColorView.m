//
//  DFCStrokeColorView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCStrokeColorView.h"

@interface DFCStrokeColorView () {
    //UIColor *_currentSelectColor;
    UIButton *_selectedButton;
}

@property (weak, nonatomic) IBOutlet UIImageView *selectColorView;
@property (weak, nonatomic) IBOutlet UIImageView *redColorView;
@property (weak, nonatomic) IBOutlet UIImageView *blackColorView;
@property (weak, nonatomic) IBOutlet UIButton *selectColorButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *blackButton;

@end

@implementation DFCStrokeColorView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.selectColorButton DFC_setLayerCorner];
    [self.redButton DFC_setLayerCorner];
    [self.blackButton DFC_setLayerCorner];
}

+ (DFCStrokeColorView *)strokeColorToolViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCStrokeColorView" owner:self options:nil];
    DFCStrokeColorView *strokeView = [arr firstObject];
    [strokeView setFirstSelected];
    
    return strokeView;
}

- (void)setFirstSelected {
    self.blackColorView.hidden = NO;
}

- (IBAction)buttonAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    _selectedButton = btn;
    
    self.blackColorView.hidden = YES;
    self.redColorView.hidden = YES;
    self.selectColorView.hidden = YES;
    
    self.selectedColor = btn.backgroundColor;
    
    [self.delegate strokeColorToolView:self
                  didSelectView:sender
                    atIndexpath:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
    
    switch (btn.tag) {
        case 0:
            self.blackColorView.hidden = NO;
            break;
        case 1:
            self.redColorView.hidden = NO;
            break;
        case 2:
            self.selectColorView.hidden = NO;
            break;
    }
}

- (void)setButtonBackgroundColor:(UIColor *)color {
    self.selectedColor = color;
    [_selectedButton setBackgroundColor:color];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

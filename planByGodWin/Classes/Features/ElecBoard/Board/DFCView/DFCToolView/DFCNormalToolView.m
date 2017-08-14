//
//  DFCNormalToolView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCNormalToolView.h"

@interface DFCNormalToolView ()

@property (weak, nonatomic) IBOutlet UIImageView *pencilSelectView;
@property (weak, nonatomic) IBOutlet UIImageView *shapeSelectView;
@property (weak, nonatomic) IBOutlet UIImageView *addSelectView;
@property (weak, nonatomic) IBOutlet UIButton *handButton;
@property (weak, nonatomic) IBOutlet UIButton *addTextButton;

@end

@implementation DFCNormalToolView

- (void)setFirstSelected {
    self.handButton.selected = YES;
    self.handButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
}

- (void)setTextSelected {
    [self setAllUnSelected];
    self.addTextButton.selected = YES;
    self.addTextButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
}

+ (DFCNormalToolView *)normalToolViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCNormalToolView" owner:self options:nil];
    DFCNormalToolView *normalToolView = [arr firstObject];
    
    return normalToolView;
}

- (void)setAllUnSelected {
    for (UIView *view in self.subviews) {
        view.backgroundColor = [UIColor clearColor];

        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
        
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
}

- (IBAction)buttonAction:(UIButton *)sender {
    [self.delegate normalToolView:self
                    didSelectView:sender
                      atIndexpath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];

    [self setAllUnSelected];
    
    sender.selected = YES;
    sender.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    
    switch (sender.tag) {
        case 0:
            self.pencilSelectView.hidden = NO;
            break;
        case 1:
            self.shapeSelectView.hidden = NO;
            break;
        case 2:
            self.addSelectView.hidden = NO;
            break;
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

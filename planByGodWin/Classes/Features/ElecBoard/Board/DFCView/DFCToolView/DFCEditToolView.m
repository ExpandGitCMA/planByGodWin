//
//  DFCEditToolView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCEditToolView.h"

@interface DFCEditToolView ()

@property (weak, nonatomic) IBOutlet UIButton *handButton;
@property (weak, nonatomic) IBOutlet UIButton *simpleButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;

@property (weak, nonatomic) IBOutlet UIButton *editButton;
@end

@implementation DFCEditToolView

- (void)setFirstSelected {
    self.handButton.selected = YES;
    self.handButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
}

- (void)setEditSelected{
    self.editButton.selected = YES;
    self.editButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
}

- (void)setAllUnSelected {
    for (UIView *view in self.subviews) {
        view.backgroundColor = [UIColor clearColor];
        
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
}

- (void)setUndoEnable:(BOOL)canUndo {
    [self.undoButton setEnabled:canUndo];
}

- (IBAction)buttonAction:(UIButton *)sender {
    [self.delegate editToolView:self
                  didSelectView:sender
                    atIndexpath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    // 撤销按钮
    if (sender.tag == 4) {
        
    } else {
        // 不是撤销按钮
        if (sender == self.simpleButton) {
            [self setAllUnSelected];
            [self setFirstSelected];
        } else {
            [self setAllUnSelected];
            sender.selected = YES;
            sender.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
        }
    }
}


+ (DFCEditToolView *)editToolViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCEditToolView" owner:self options:nil];
    DFCEditToolView *editToolView = [arr firstObject];
    [editToolView setFirstSelected];
    
    return editToolView;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

//
//  DFCStudentOnClassExitView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCStudentOnClassExitView.h"

@interface DFCStudentOnClassExitView ()

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@end


@implementation DFCStudentOnClassExitView

+ (DFCStudentOnClassExitView *)studentOnClassExitViewWithFrame:(CGRect)frame {    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCStudentOnClassExitView" owner:self options:nil];
    DFCStudentOnClassExitView *exitView = [arr firstObject];
    return exitView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.yesButton DFC_setLayerCorner];
    [self.noButton DFC_setLayerCorner];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
}

- (IBAction)yesAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(studentOnClassExitView:didTapExitType:)]) {
        [self.delegate studentOnClassExitView:self didTapExitType:kStudentOnClassExitViewTypeSave];
    }
}

- (IBAction)noAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(studentOnClassExitView:didTapExitType:)]) {
        [self.delegate studentOnClassExitView:self didTapExitType:kStudentOnClassExitViewTypeNotSave];
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

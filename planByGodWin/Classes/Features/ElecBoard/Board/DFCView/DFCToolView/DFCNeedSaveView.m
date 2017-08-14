//
//  DFCNeedSaveView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCNeedSaveView.h"
#import "DFCBoardCareTaker.h"

@interface DFCNeedSaveView ()

@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (weak, nonatomic) IBOutlet UIButton *giveupButton;

@end

@implementation DFCNeedSaveView

+ (DFCNeedSaveView *)needSaveViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCNeedSaveView" owner:self options:nil];
    DFCNeedSaveView *needSaveView = [arr firstObject];
    return needSaveView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.openButton DFC_setLayerCorner];
    [self.giveupButton DFC_setLayerCorner];
}

- (IBAction)openAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(needSaveViewDidOpen:)]) {
        [self.delegate needSaveViewDidOpen:self];
    }
}

- (IBAction)giveupAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(needSaveViewDidGiveUP:)]) {
        [self.delegate needSaveViewDidGiveUP:self];
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

//
//  DFCUdpJoinClassSuccessContentView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUdpJoinClassSuccessContentView.h"

@interface DFCUdpJoinClassSuccessContentView ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *inviteCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UIView *contentBaackgroundView;

@end

@implementation DFCUdpJoinClassSuccessContentView

+ (instancetype)joinClassSuccessContentViewWithFrame:(CGRect)frame {
    DFCUdpJoinClassSuccessContentView *joinSuccessContentView = [[[NSBundle mainBundle] loadNibNamed:@"DFCUdpJoinClassSuccessContentView" owner:self options:nil] firstObject];
    joinSuccessContentView.frame = frame;
    return joinSuccessContentView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentBaackgroundView DFC_setSelectedLayerCorner];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

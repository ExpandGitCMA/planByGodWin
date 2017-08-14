//
//  DFCShareStoreProtocolCell.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCShareStoreProtocolCell.h"

@interface DFCShareStoreProtocolCell ()
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@end

@implementation DFCShareStoreProtocolCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self agreeTheProtocol:self.agreeButton];
}

// 同意协议
- (IBAction)agreeTheProtocol:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.agreementBlock) {
        self.agreementBlock(sender.selected);
    }
}
@end

//
//  DFCChargeView.m
//  planByGodWin
//
//  Created by dfc on 2017/4/28.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCChargeView.h"

@interface DFCChargeView ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation DFCChargeView


+ (instancetype)chargeView{
    
    return [[[NSBundle mainBundle]loadNibNamed:@"DFCChargeView" owner:nil options:nil] firstObject];
}

- (void)setIsCharge:(BOOL)isCharge{
    _isCharge = isCharge;
    
    _iconImgView.hidden = _isCharge;
    _projectNameLabel.hidden = _isCharge;
    
    if (_isCharge) {    //  收费
        _messageLabel.text = DFChargeCoursewareTitle;
        
        [_confirmButton setTitle:DFCBuyTitle forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor orangeColor]];
    }else { // 免费
        _messageLabel.text = DFCFreeCoursewareTitle;
        
        [_confirmButton setTitle:DFCDownloadTitle forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor: kUIColorFromRGB(ButtonGreenColor)];
    }
}


/**
 仅在收费课件下载付费完成后调用此方法
 */
- (void)paySuccess{ // 收费课件在支付完成后，界面提示文字修改
    _messageLabel.text = DFCPaySuccessTitle;
    [_confirmButton setTitle:DFCDownloadTitle forState:UIControlStateNormal];
    [_confirmButton setBackgroundColor: kUIColorFromRGB(ButtonGreenColor)];
}

- (void)downloadFromMyStore{
    _messageLabel.text = DFCCoursewareInMyStoreTitle;
    [_confirmButton setTitle:DFCDownloadTitle forState:UIControlStateNormal];
    [_confirmButton setBackgroundColor: kUIColorFromRGB(ButtonGreenColor)];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _projectNameLabel.text = DFCApplicationTitle;
    [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmButton DFC_setLayerCorner];
    
    [_cancelButton  setTitle:DFCCancelTitle forState:UIControlStateNormal];
    [_cancelButton setBackgroundColor:[UIColor darkGrayColor]];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton DFC_setLayerCorner];
}

- (IBAction)buttonClick:(UIButton *)sender {
    // 10 con   11 cancel
    if(self.delegate && [self.delegate respondsToSelector:@selector(chargeView:clickButton:)]){
        [self.delegate chargeView:self clickButton:sender];
    }
}

@end

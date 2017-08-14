//
//  DFCOrderPaySuccessView.m
//  planByGodWin
//
//  Created by dfc on 2017/5/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCOrderPaySuccessView.h"

@interface DFCOrderPaySuccessView ()
@property (weak, nonatomic) IBOutlet UILabel *orderCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *sellerCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;


@property (weak, nonatomic) IBOutlet UIButton *selectPayRecords;
@end

@implementation DFCOrderPaySuccessView
+(instancetype)orderPaySuccessViewWithFrame:(CGRect)frame{
    DFCOrderPaySuccessView *paySuccessView = [[[NSBundle mainBundle]loadNibNamed:@"DFCOrderPaySuccessView" owner:nil options:nil] firstObject];
    paySuccessView.frame = frame;
    return paySuccessView;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.selectPayRecords DFC_setLayerCorner];
    
    _tipLabel.layer.cornerRadius = 5;
    _tipLabel.layer.borderColor = kUIColorFromRGB(BoardLineColor).CGColor;
    _tipLabel.layer.borderWidth = 1.0;
    
    // 开启计时器 3s之后自动下载
    __block NSInteger duration = 3;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (duration>=0) {
//                [sender setTitle:[NSString stringWithFormat:@"%lu s",duration] forState:UIControlStateNormal];
                _tipLabel.text = [NSString stringWithFormat:@"即将开始下载 (%ld s)",duration];
                duration--;
            }else {
                dispatch_source_cancel(timer);
//                [sender setTitle:@"获取验证码" forState:UIControlStateNormal];
//                sender.enabled = YES;
                _tipLabel.hidden = YES;
            }
        });
    });
    dispatch_resume(timer);
}

- (void)setInfo:(NSDictionary *)info{
    _orderCodeLabel.text = [NSString stringWithFormat:@"编号：%@",info[@"tradeNo"]];
    _priceLabel.text = [NSString stringWithFormat:@"金额：%.2f",[info[@"money"] floatValue]];
    _sellerCodeLabel.text = @"商户名称：浙江智汇信息工程有限公司";
    
    //时间戳转换时间
    NSString *timeStampString  =[NSString stringWithFormat: @"%ld", [[info objectForKey:@"createTime"] integerValue]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
    [presentFormat setDateFormat:@"YYYYMMdd HH:mm:ss"];
    _dateLabel.text = [NSString stringWithFormat:@"时间：%@",[presentFormat stringFromDate:date]];
}

- (IBAction)selectRecords:(UIButton *)sender {
    DEBUG_NSLog(@"查看购买记录");
}

@end

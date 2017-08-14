//
//  OrderPayAlipayView.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "OrderPayAlipayView.h"
#import "NSString+Emoji.h"
@interface OrderPayAlipayView ()
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UIImageView *payImgUrl;
@property (weak, nonatomic) IBOutlet UILabel *payName;
@property (weak, nonatomic) IBOutlet UIImageView *payCode;
@property (weak, nonatomic) IBOutlet UILabel *payCodeName;
@property (weak, nonatomic) IBOutlet UILabel *timer;

@end

@implementation OrderPayAlipayView

+(OrderPayAlipayView*)initWithFrame:(CGRect)frame{
    OrderPayAlipayView *orderPay = [[[NSBundle mainBundle] loadNibNamed:@"OrderPayAlipayView" owner:self options:nil] firstObject];
    orderPay.frame = frame;
    
    return orderPay ;
}

//  调用支付接口返回的订单信息生成支付二维码
- (void)getOrderInfoURlWithCoursewareCode:(NSString *)coursewareCode{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:coursewareCode forKey:@"coursewareCode"];
//    payCode
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.payCode animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"正在生成...";
    hud.label.textColor = [UIColor whiteColor];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetPayOrderInfoURL identityParams:params completed:^(BOOL ret, id obj) {
        [hud removeFromSuperview];
        DEBUG_NSLog(@"获取支付信息-%@",obj);
        if (ret) {
            NSString *orderQrCode = obj[@"orderQrCode"];
            if (orderQrCode.length) {
                UIImage *payImg = [NSString createImgWithString:orderQrCode size:self.payCode.bounds.size];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.payCode.image = payImg;
                });
            }else {
                DEBUG_NSLog(@"获取支付url为空");
            }
        }else {
            DEBUG_NSLog(@"获取支付信息失败");
        }
    }];
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    CGFloat price = [goodsModel.price floatValue];
    NSString *p = [NSString stringWithFormat:@"¥ %.2f",price];
    [self layoutPriceLabelWithPrice:p];
    if (self.orderURL.length) {
        UIImage *payImg = [NSString createImgWithString:self.orderURL size:self.payCode.bounds.size];
        self.payCode.image = payImg;
    }else {
        [self getOrderInfoURlWithCoursewareCode:goodsModel.coursewareCode];
    }
}

-(void)setPayment:(OrderPaymenMode)payment{
    switch (payment) {
        case OrderPaymenPayAlipay:{
        
        }
            break;
        case OrderPaymenWeChat:{
            _payImgUrl.image = [UIImage imageNamed:@"orderWeChat"];
            _payName.text = @"微信支付";
            _payCodeName.text = @"请使用微信扫描二维码完成支付(15分钟内有效)";
        }
            break;
        default:
            break;
    }
}

- (void)layoutPriceLabelWithPrice:(NSString *)price{
    NSString *str1 = @"应付金额:  ";
    long len1 = [str1 length];
    NSString *nameStr = price;
    NSString *str = [NSString stringWithFormat:@"%@%@",str1,nameStr];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc]initWithString:str];
    [str2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:NSMakeRange(0,len1)];
    _price.attributedText = str2;
}

#pragma mark-模拟完成支付回调
//- (void)pay:(UIGestureRecognizer *)sender {
//        
//    if ([self.protocol respondsToSelector:@selector(payment:completed:)]) {
//        [self.protocol payment:self completed:nil];   
//    }
//}

-(void)awakeFromNib{
    [super awakeFromNib];
//    [self layoutPriceLabel];
    _timer.text = [NSString stringWithFormat:@"%@%@",@"创建时间:",
                   [self getNowaday]];
    
//    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pay:)];
//    [self.payCode addGestureRecognizer:tap];
    
}

-(NSString*)getNowaday{
    NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
    [presentFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *nowaday = [presentFormat stringFromDate:[NSDate date]];
    return nowaday;
}
-(void)dealloc{
    DEBUG_NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}
@end

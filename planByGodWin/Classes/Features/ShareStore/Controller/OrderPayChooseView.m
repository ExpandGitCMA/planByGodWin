//
//  OrderPayChooseView.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "OrderPayChooseView.h"
#import "DFCButton.h"

@interface OrderPayChooseView ()
@property (weak, nonatomic) IBOutlet DFCButton *orderPay;
@property (weak, nonatomic) IBOutlet DFCButton *aliPay;
@property (weak, nonatomic) IBOutlet DFCButton *weChat;
@property (assign,nonatomic) NSUInteger signNum;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;

@property (weak, nonatomic) IBOutlet UILabel *coursewareNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *coursewareCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *coursewareSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailPriceLabel;

@property (nonatomic,strong) DFCButton *selectedBtn;    // 选中的按钮
@end

@implementation OrderPayChooseView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

+(OrderPayChooseView*)initWithFrame:(CGRect)frame{
    OrderPayChooseView *orderPay = [[[NSBundle mainBundle] loadNibNamed:@"OrderPayChooseView" owner:self options:nil] firstObject];
    orderPay.frame = frame;
    [orderPay.orderPay setKey:Subkeylogin];
    [orderPay.aliPay   setButtonPayStyle:PayColor];
    [orderPay.weChat setButtonPayStyle:PayColor];
    return orderPay ;
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _coursewareNameLabel.text = goodsModel.coursewareName;
    _coursewareCodeLabel.text = [NSString stringWithFormat:@"编号:%@",goodsModel.coursewareCode];
    
    _coursewareSizeLabel.text = goodsModel.coursewareSize.length? [NSString stringWithFormat:@"文件大小:%@",goodsModel.coursewareSize]:@"文件大小:暂无";
    _authorLabel.text = [NSString stringWithFormat:@"发布者:%@",goodsModel.authorName];
    CGFloat price = [goodsModel.price floatValue];
    
    _priceLabel.text = [NSString stringWithFormat:@"售价: %.2f",price];
    _detailPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f",price];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    //  默认同意
    self.agreeBtn.selected = YES;
    
    [self borderStyleNormalWithButton:_aliPay];
    [self borderStyleNormalWithButton:_weChat];
}

#pragma mark-action
// 去支付
- (IBAction)orderPay:(DFCButton *)sender {
    if ([self.protocol respondsToSelector:@selector(orderpay:indexPath:)]) {
        [self.protocol orderpay:self indexPath:self.selectedBtn.tag];
    }
}

// 同意交易说明
- (IBAction)agreePay:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.protocol && [self.protocol respondsToSelector:@selector(orderpay:agree:)]) {
        [self.protocol orderpay:self agree:sender];
    }
}

// 普通样式的按钮
- (void)borderStyleNormalWithButton:(DFCButton *)button{
    button.layer.borderColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1].CGColor;
//    button.layer.borderWidth = 1;
}

- (void)setSelectedBtn:(DFCButton *)selectedBtn{
    _selectedBtn = selectedBtn;
    _selectedBtn.layer.borderColor = kUIColorFromRGB(ButtonTypeColor).CGColor;
    _selectedBtn.layer.borderWidth = 1;
}

// 选择支付方式
- (IBAction)payment:(DFCButton *)sender {
    if (self.selectedBtn) {
        [self borderStyleNormalWithButton:self.selectedBtn];
    }
    self.selectedBtn = sender;
    
//    if (self.signNum!=0) {
//        UIButton *tempB = (UIButton *)[self viewWithTag:self.signNum];
//        tempB.selected = NO;
//    }
//    sender.selected = YES;
//    self.signNum = sender.tag;
//    DEBUG_NSLog(@"sender=%ld",sender.tag);
}

-(void)dealloc{
    DEBUG_NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}
@end

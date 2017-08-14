//
//  OrderPayViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/30.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "OrderPayViewController.h"
#import "OrderPayFactoryProtocol.h"

@interface OrderPayViewController ()<OrderPayProtocol>
{
    BOOL _isAgree;  // 是否同意交易说明
    BOOL _isPaySuccess; // 是否支付完成
}
@property(nonatomic,retain)UIButton*orderNo;
@property(nonatomic,retain)UIButton*cancel;
@property(nonatomic,strong)OrderPayView*orderPay;
@property(nonatomic,assign)PayViewStyleType type;
@property(nonatomic,copy)NSArray *arraySource;
@end

@implementation OrderPayViewController
-(instancetype)initWithOrderPayArraySource:(NSArray*)arraySource  type:(PayViewStyleType)type{
    if (self = [super init]) {
        self.type = type;
//        self.arraySource = arraySource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     [self initView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [DFCNotificationCenter addObserver:self selector:@selector(paySuccess:) name:DFCPaySuccessNotification object:nil];
}

-(void)dealloc{
    [DFCNotificationCenter removeObserver:self name:DFCPaySuccessNotification object:nil];
}

/**
 支付成功通知
 */
- (void)paySuccess:(NSNotification *)notification{
    id info = notification.object;
    DEBUG_NSLog(@"支付成功回调的消息-%@",info);
    if ([info isKindOfClass:[NSDictionary class]]) {
        _isPaySuccess = YES;
        // 支付成功界面
        _orderPay = [OrderPayFactoryProtocol orderPayViewWithFrame:self.view.frame chose:OrderPaySuccess ];
        _orderPay.info = info;
        _orderPay.protocol = self;
        DFCOrderPaySuccessView *successView = (DFCOrderPaySuccessView *)_orderPay;
        
        @weakify(self)
        successView.startDownloadBlock = ^{
            @strongify(self)
            // 开始下载
            if (self.downloadBlock) {
                self.downloadBlock();
            }
        };
        [self.view addSubview:_orderPay];
        
    }else {
        DEBUG_NSLog(@"the msg type is not NSDictionary !");
    }
}

-(void)initView{
    
    _isAgree = YES; // 默认同意
    
    [self cancel];
    [self orderNo];
    [self orderNoPay];
    if (self.type==HistoryPage) {   // 历史记录
         [self initOrderPayView:(OrderPayStyle)HistoryPage];
    }else if (self.isFromPurchaseList){
        [self initOrderPayView:OrderPayAlipay];
    } else{  // 支付界面
          [self initOrderPayView:OrderPayChoose];
    }
}
#pragma mark - OrderPayProtocol
- (void)orderpay:(OrderPayChooseView *)orderpay agree:(UIButton *)sender{
    _isAgree = !_isAgree;
}


/**
 去支付
 */
-(void)orderpay:(OrderPayChooseView*)payment  indexPath:(NSInteger)indexPath{
    if (indexPath==0) { // 1 支付宝        2   微信
        [DFCProgressHUD showText:DFCChoosePayWay atView:self.view animated:YES hideAfterDelay:1];
        return;
    }
    if (indexPath == 2){
        [DFCProgressHUD showText:@"微信支付暂不支持，请选择支付宝支付" atView:self.view animated:YES hideAfterDelay:1];
        return;
    }
    
    if (!_isAgree) {    
        [DFCProgressHUD showText:DFCReadAndAgreeTradeShow atView:self.view animated:YES hideAfterDelay:1];
        return;
    }
    
    [_orderPay removeFromSuperview];
    [self initOrderPayView:(OrderPayStyle)indexPath];
    [self transformAnimation:kCATransitionPush];
}

-(void)payment:(OrderPayAlipayView *)payment completed:(NSString *)completed{
    
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(paymentOrder:completed:)]&&self.delegate) {
                [self.delegate paymentOrder:self completed:completed];
            }
        }];
}
-(void)initOrderPayView:(OrderPayStyle)pay{
    _orderPay = [OrderPayFactoryProtocol orderPayViewWithFrame:self.view.frame chose:pay ];
    if (pay == OrderPayAlipay && self.OrderURL.length) {
        OrderPayAlipayView *alipay = (OrderPayAlipayView *)_orderPay;
        alipay.orderURL = self.OrderURL;
    }
    _orderPay.goodsModel = self.goodsModel;
    _orderPay.protocol = self;
    
    [self.view addSubview:_orderPay];
}

-(void)orderNoPay{
    if (self.type==HistoryPage) {
         self.title = @"购买记录";
         [_cancel setTitle:@"关闭" forState:UIControlStateNormal];
    }else{
        self.title = @"订单结算";
    }
    [self.navigationController.navigationBar
                                setTitleTextAttributes:
                                @{NSFontAttributeName:
                               [UIFont systemFontOfSize:19],
    NSForegroundColorAttributeName:
                                      kUIColorFromRGB(ButtonTypeColor)}];
}
-(UIButton*)cancel{
    if (!_cancel) {
        _cancel= [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 60, 30)];
        [_cancel setTitle:@"取消" forState:UIControlStateNormal];
        _cancel.titleLabel.font = [UIFont systemFontOfSize:17];
        [_cancel setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
        [_cancel addTarget:self action:@selector(cancelPay:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_cancel];
    }
    return _cancel;
}

-(UIButton*)orderNo{
    if (!_orderNo) {
        NSString *account  =  [NSString stringWithFormat:@"%@%@",@"帐号: ", [[NSUserDefaultsManager shareManager]getAccounNumber]];
        _orderNo= [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 120, 30)];
        [_orderNo setTitle:account forState:UIControlStateNormal];
        _orderNo.titleLabel.font = [UIFont systemFontOfSize:17];
        [_orderNo setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_orderNo];
    }
    return _orderNo;
}

#pragma mark-action
-(void)cancelPay:(UIButton*)sender{
    
    if (_isPaySuccess) {
        // 支付完成后关闭当前界面进行下载
        if (self.paySuccessBlock) {
            self.paySuccessBlock();
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    switch (self.type) {
        case OrderPayPage:{
            @weakify(self)
            KDBlockAlertView *alertView = [[KDBlockAlertView alloc] initWithTitle:@"确认要离开收银台" message:@"超过支付时效后订单将被取消,请尽快完成支付;若已支付,请稍等" block:^(NSInteger buttonIndex) {
                @strongify(self)
                if (buttonIndex == 0) {
                    return;
                } else if (buttonIndex == 1) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
            [alertView show];
        }
            break;
        case HistoryPage:{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (CGSize)preferredContentSize{
    return CGSizeMake(SCREEN_WIDTH*2/3, SCREEN_HEIGHT*2/3);
}

- (void)transformAnimation:(NSString *)AnimationType {
    CATransition *anima = [CATransition animation];
    anima.type = AnimationType;//设置动画的类型
    anima.subtype = kCATransitionFromRight; //设置动画的方向
    anima.duration = 0.28;
    [_orderPay.layer addAnimation:anima forKey:AnimationType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

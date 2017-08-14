//
//  DFCIncashController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCIncashController.h"
#import "DFCAddAccountController.h"
#import "NSString+Emoji.h"

@interface DFCIncashController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIButton *addAccountButton;
@property (weak, nonatomic) IBOutlet UITextField *incashTextField;
@property (weak, nonatomic) IBOutlet UITextField *psdTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet UIView *successView;
@property (weak, nonatomic) IBOutlet UILabel *incashLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceAfterIncashLabel;

@property (nonatomic,strong) UIButton *rightBtn;
 
@end

@implementation DFCIncashController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
 设置界面
 */
- (void)setupView{
    self.navigationController.navigationBar.translucent = NO;
    
    if (self.accountModel.accountNum.length){    //  已绑定账号
        _accountLabel.hidden = NO;
        _addAccountButton.hidden = YES;
        _accountLabel.text = self.accountModel.accountNum;
    }
    _balanceLabel.text = [NSString stringWithFormat:@"¥ %.2f",self.accountModel.balance];
    
    self.navigationItem.title = @"提现";
    
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 35)];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [self.confirmButton setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    self.successView.hidden = YES;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]]; 
}

/**
 取消
 */
- (void)cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/**
 添加支付宝账号
 */
- (IBAction)addAccount:(UIButton *)sender {
    DFCAddAccountController *addVC = [[DFCAddAccountController  alloc]init];
    addVC.bindBlock = ^(NSString *accountNum,NSString *accountName){
        self.accountModel.accountNum = accountNum;
        self.accountModel.accountName = accountName;
        [self setupView];
        if (self.bindSuccessBlock) {
            self.bindSuccessBlock(accountNum, accountName);
        }
    };
    [self.navigationController pushViewController:addVC animated:YES];
}

/**
 确认提现
 */
- (IBAction)confirm:(UIButton *)sender {
    DEBUG_NSLog(@"确认提现");
    NSString *incash = self.incashTextField.text;
    if (self.accountModel.accountNum.length == 0){
        [DFCProgressHUD showText:@"尚未绑定支付宝账号" atView:self.view animated:YES hideAfterDelay:1];
        return;
    }else if (incash.length == 0){
        [DFCProgressHUD showText:@"输入您要提取的金额（整数，元）" atView:self.view animated:YES hideAfterDelay:1];
        return;
    }else if (![NSString isPureInt:incash]){
        [DFCProgressHUD showText:@"只能提取整数（元）" atView:self.view animated:YES hideAfterDelay:1];
        return;
    }else if (incash.floatValue >self.accountModel.balance){
        [DFCProgressHUD showText:@"余额不足" atView:self.view animated:YES hideAfterDelay:1];
        return;
    }else if (self.psdTextField.text.length == 0){
        [DFCProgressHUD showText:@"请输入提现密码" atView:self.view animated:YES hideAfterDelay:1];
        return;
    }
    
    sender.enabled = NO;
    MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在操作" atView:self.view animated:YES];
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSString *value = self.incashTextField.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:[self.psdTextField.text md5Hash] forKey:@"password"];
    [params SafetySetObject:@([value integerValue])  forKey:@"cashAmount"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_Incash identityParams:params completed:^(BOOL ret, id obj) {
        sender.enabled = YES;
        [hud hideAnimated:YES];
        if (ret) {
            DEBUG_NSLog(@"提现成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.successView.hidden = NO;
                self.incashLabel.text = [NSString stringWithFormat:@"提现金额：%.2f元",incash.floatValue];
                self.balanceAfterIncashLabel.text = [NSString stringWithFormat:@"当前可提现金额：%.2f元",(self.accountModel.balance - incash.floatValue)];
                [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
                if (self.incashBlock) {
                    self.incashBlock([value floatValue]);
                }
                
                for (UIView *subview in self.contentView.subviews) {
                    if (![subview isEqual:self.successView]) {
                        subview.hidden = YES;
                    }
                }
            });
        }else {
            DEBUG_NSLog(@"提现失败-%@",obj);
            [DFCProgressHUD showErrorWithStatus:obj];
        }
    }];
}


- (CGSize)preferredContentSize{
    return CGSizeMake(450, 390);
}

@end

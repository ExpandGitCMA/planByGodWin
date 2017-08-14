//
//  DFCAddAccountController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAddAccountController.h"

typedef NS_ENUM(NSInteger,DFCAddAccountState) {
    DFCAddAccountReady ,    // 输入账号、姓名以及验证
    DFCAddAccountFinishVerify,  // 完成验证
    DFCAddAccountEnterIncashPsd,    //  填写提现密码
    DFCAddAccountSuccessfully   //   完成添加账号
};

@interface DFCAddAccountController ()
// 1
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

// 2 验证完成，输入密码
@property (weak, nonatomic) IBOutlet UITextField *psdTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPsdTextField;

// 3 添加完成
@property (weak, nonatomic) IBOutlet UIImageView *doneImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountTextFieldTop;
@property (weak, nonatomic) IBOutlet UILabel *finishTipLabel;

@property (nonatomic,strong) UIButton *getCodeButton;
@property (nonatomic,assign) DFCAddAccountState addState;
@property (nonatomic,strong) UIButton *rightBtn;
@end

@implementation DFCAddAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupView];
}

/**
 设置界面
 */
- (void)setupView{
    self.navigationController.navigationBar.translucent = NO;
    
    NSString *phone = [DFCUserDefaultManager currentPhone];
    if (phone.length) {
        _tipLabel.text = [NSString stringWithFormat:@"用绑定的手机%@获取验证码来完成身份验证",phone];
    }else{
        DEBUG_NSLog(@"手机号为空");
        _tipLabel.text = @"手机号为空，请到个人中心填写";
    }
    
    self.navigationItem.title = @"添加支付宝账号";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 35)];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.rightBtn = rightBtn;
    
    self.navigationItem.leftBarButtonItem = nil;
    
    // 获取验证码textField的右视图
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, self.verifyCodeTextField.bounds.size.height)];
    UIButton *getCodeButton = [[UIButton alloc]initWithFrame:rightView.bounds];
    self.getCodeButton = getCodeButton;
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    getCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [getCodeButton setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    [getCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getCodeButton addTarget:self action:@selector(getCode:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:getCodeButton];
    
    self.verifyCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    self.verifyCodeTextField.rightView = rightView;
    [self.verifyCodeTextField DFC_setSelectedLayerCorner];
    
    [self.confirmButton DFC_setSelectedLayerCorner];
    [self.confirmButton setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    
    self.addState = DFCAddAccountReady;
}

- (void)setAddState:(DFCAddAccountState)addState{
    _addState = addState;
    switch (addState) {
        case DFCAddAccountReady:
        {
            self.psdTextField.hidden = YES;
            self.repeatPsdTextField.hidden = YES;
            
            self.doneImageView.hidden = YES;
            self.finishTipLabel.hidden = YES;
        }
            break;
            
        case DFCAddAccountFinishVerify:
        {
            
            self.accountTextFieldTop.constant = 100;
            self.nameTextField.enabled = NO;
            self.accountTextField.enabled = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.tipLabel.hidden = YES;
                self.verifyCodeTextField.hidden = YES;
                [self.view layoutIfNeeded];
            }];
        }
            break;
            
        case DFCAddAccountEnterIncashPsd:
        {
            self.accountTextField.borderStyle = UITextBorderStyleNone;
            self.nameTextField.borderStyle = UITextBorderStyleNone;
            
            self.psdTextField.hidden  = NO;
            self.repeatPsdTextField.hidden = NO;
            
            self.accountTextFieldTop.constant = 40;
            [UIView animateWithDuration:0.25 animations:^{
                [self.view layoutIfNeeded];
            }];
        }
            break;
            
        case DFCAddAccountSuccessfully:
        {
            self.psdTextField.hidden = YES;
            self.repeatPsdTextField.hidden = YES;
            self.confirmButton.hidden = YES;
            
            self.accountTextFieldTop.constant = 240;
            [UIView animateWithDuration:0.1 animations:^{
                [self.view layoutIfNeeded];
                self.doneImageView.hidden = NO;
                self.finishTipLabel.hidden = NO;
            }];
        }
            break;
            
        default:
            break;
    }
}

/**
 点击获取验证码
 */
- (void)getCode:(UIButton *)sender{
    NSString *phone = [DFCUserDefaultManager currentPhone];
    if(phone.length == 0){
        [DFCProgressHUD showLoadText:@"尚未设置手机号" atView:self.view animated:YES];
        return;
    }
    
    // 发送验证码
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:phone forKey:@"mobile"];
    
    sender.enabled = NO;
    MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在发送" atView:self.view animated:YES];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetVerifyCode identityParams:params completed:^(BOOL ret, id obj) {
        sender.enabled = YES;
        [hud hideAnimated:YES];
        
        if (ret) {
            DEBUG_NSLog(@"已发送验证码");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendCode:sender];
            });
        }else {
            DEBUG_NSLog(@"发送验证码失败");
            [DFCProgressHUD showErrorWithStatus:@"发送失败，请重新发送"];
        }
    }];
}

/**
倒计时
 */
- (void)sendCode:(UIButton *)sender{
    sender.enabled = NO;
    __block NSInteger duration = 60;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (duration>=0) {
                [sender setTitle:[NSString stringWithFormat:@"%lu s",duration] forState:UIControlStateNormal];
                duration--;
            }else {
                dispatch_source_cancel(timer);
                [sender setTitle:@"获取验证码" forState:UIControlStateNormal];
                sender.enabled = YES;
            }
        });
    });
    dispatch_resume(timer);
}

/**
 取消
 */
- (void)cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirm:(UIButton *)sender {
    
    switch (self.addState) {
        case DFCAddAccountReady:
        {
            if (self.accountTextField.text.length == 0) {
                [DFCProgressHUD showText:@"请输入您的支付宝账号" atView:self.view animated:YES hideAfterDelay:1];
                return;
            }else if (self.nameTextField.text.length == 0) {
                [DFCProgressHUD showText:@"请输入支付宝对应的姓名" atView:self.view animated:YES hideAfterDelay:1];
                return;
            }else if (self.verifyCodeTextField.text.length == 0){
                [DFCProgressHUD showText:@"请输入验证码" atView:self.view animated:YES hideAfterDelay:1];
                return;
            }
            self.addState = DFCAddAccountFinishVerify;
        }
            break;
            
        case DFCAddAccountFinishVerify:
        {
            self.addState = DFCAddAccountEnterIncashPsd;
        }
            break;
            
        case DFCAddAccountEnterIncashPsd:
        {
            if (self.psdTextField.text.length ==0) {
                [DFCProgressHUD showText:@"请输入提现密码" atView:self.view animated:YES hideAfterDelay:1];
                return;
            }else if (self.repeatPsdTextField.text.length == 0){
                [DFCProgressHUD showText:@"再次输入提现密码" atView:self.view animated:YES hideAfterDelay:1];
                return;
            }else if (![self.psdTextField.text isEqualToString:self.repeatPsdTextField.text]){
                [DFCProgressHUD showText:@"两次密码输入不一致" atView:self.view animated:YES hideAfterDelay:1];
                return;
            }
            sender.enabled = NO;
            
            MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在操作" atView:self.view animated:YES];
            
            NSString *accountNum = self.accountTextField.text;
            NSString *accountName = self.nameTextField.text;
            
            NSString *userCode = [DFCUserDefaultManager getAccounNumber];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
            [params SafetySetObject:userCode forKey:@"userCode"];
            [params SafetySetObject:accountNum forKey:@"accountNo"];
            [params SafetySetObject:accountName forKey:@"name"];
            [params SafetySetObject:[self.psdTextField.text md5Hash] forKey:@"password"];
            [params SafetySetObject:self.verifyCodeTextField.text forKey:@"authCode"];
            
            [[HttpRequestManager sharedManager] requestPostWithPath:URL_AddAlipayAccounts identityParams:params completed:^(BOOL ret, id obj) {
                sender.enabled = YES;
                [hud hideAnimated:YES];
                if (ret) {
                    DEBUG_NSLog(@"绑定支付宝成功");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.addState = DFCAddAccountSuccessfully;
                        [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
                        if (self.bindBlock) {
                            self.bindBlock(accountNum, accountName);
                        }
                        [self.view endEditing:YES];
                    });
                }else {
                    DEBUG_NSLog(@"绑定支付宝失败");
                    [DFCProgressHUD showErrorWithStatus:@"绑定支付宝失败"];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

- (CGSize)preferredContentSize{
    return CGSizeMake(450, 390);
}
@end

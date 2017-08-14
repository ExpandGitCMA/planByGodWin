//
//  DFCLoginView.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCLoginView.h"
#import "DFCButton.h"
#import "DFCTextField.h"
#import "DFCClarityView.h"
#import "DFCTPassWordField.h"
#import "DFCEntery.h"
#import "DFCHomeViewController.h"
#import "DFCRabbitMqChatMessage.h"

@interface DFCLoginView ()<UITextFieldDelegate,PassWordFieldDelegate>
@property(nonatomic,strong)DFCButton *login;
@property (nonatomic,strong)DFCClarityView *clarityView;
@property (nonatomic,strong)DFCTextField *accountTextField;
@property (nonatomic,strong)DFCTPassWordField *passWordField;
@property(nonatomic,assign)NSInteger row;
@property (nonatomic,strong,readonly)NSString*token;
@end
static float const showtime = 0.25;
@implementation DFCLoginView
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self  addsubviews];
    }
    return self;
}

- (void)addsubviews{
    [self login];
    [self passWordField];
    [self accountTextField];
    //模拟自动登陆
    if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[self getAccounNumber]]==NO&&[[NSUserBlankSimple shareBlankSimple]isBlankString:[self getPassWord]]==NO) {
        [self loginRequest];
    }
}

-(DFCTextField*)accountTextField{
    if (!_accountTextField) {
        CGFloat Subkey ;
        if (SCREEN_WIDTH==isiPadePro_WIDTH) {
            Subkey = SCREEN_HEIGHT/2 -TextFieldHeight;
        }else{
            Subkey = _passWordField.frame.origin.y-10-TextFieldHeight;
        }
        _accountTextField = [[DFCTextField alloc]initWithFrame:CGRectMake(0 ,Subkey,TextFieldWidth,TextFieldHeight) imgIcon: @"register_phone" holder:@"请输入帐号"];
        _accountTextField.delegate = self;
        _accountTextField.text = [self getAccounNumber];
        [self addSubview:_accountTextField];
    }
    return _accountTextField;
}

-(DFCTPassWordField*)passWordField{
    if (!_passWordField) {
        CGFloat Subkey ;
        if (SCREEN_WIDTH==isiPadePro_WIDTH) {
            Subkey = SCREEN_HEIGHT/2+15;
        }else{
            Subkey = _login.frame.origin.y-30-TextFieldHeight;
        }
        _passWordField = [[DFCTPassWordField alloc]initWithFrame:CGRectMake(0,Subkey, TextFieldWidth, TextFieldHeight) imgIcon:@"register_password" holder:@"请输入密码"];
        _passWordField.delegate = self;
        _passWordField.passWorddelegate =self;
        _passWordField.text = [self getPassWord];
        if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[self getPassWord]]==NO) {
               _clarityView.hidden = YES;
        }
        [self addSubview:_passWordField];
    }
    return _passWordField;
}

-(DFCButton*)login{
    if (!_login) {
        CGFloat Subkey ;
        if (SCREEN_WIDTH==isiPadePro_WIDTH) {
            Subkey = SCREEN_HEIGHT-SubkeySpace-SubkeyLoginHeight*2.5;
        }else{
            Subkey = SCREEN_HEIGHT-SubkeySpace-SubkeyLoginHeight;
        }
        _login = [[DFCButton alloc] initWithFrame:CGRectMake(0, Subkey,SubkeyLoginWidth, SubkeyLoginHeight)];
        [_login setKey:Subkeylogin];
        [_login setTitle:@"登录" forState:UIControlStateNormal];
        [_login addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        _clarityView = [[DFCClarityView alloc] initWithFrame:_login.frame];
        [self addSubview:_login];
        [self addSubview:_clarityView];
    }
    return _login;
}
#pragma mark-action
- (void)login:(UIButton *)sender{
       [self loginRequest];
}

-(void)loginRequest{
    [DFCSyllabusUtility showActivityIndicator];
    if ([[NSUserDefaultsManager shareManager]isUserMark]) {
        [self loginNetworStudent];
    }else{
        [self loginNetworkTeacher];
    }
}

-(void)loginNetworkTeacher{
    @weakify(self)
    [[HttpRequestManager sharedManager]requestPostWithPath:URL_Login params:[self params] completed:^(BOOL ret, id obj) {
        @strongify(self)
        if (ret) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _token = [obj objectForKey:@"token"];
                 [self savaCacheDataSource:obj];
            });
            DEBUG_NSLog(@"教师登陆=%@",obj);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCProgressHUD showErrorWithStatus:obj duration:1.5];
            });
        }
    }];
      [DFCSyllabusUtility hideActivityIndicator];
}
#pragma mark-学生登陆
-(void)loginNetworStudent{
    @weakify(self)
    [[HttpRequestManager sharedManager]requestPostWithPath:URL_StudentLogin params:[self studentparams] completed:^(BOOL ret, id obj) {
        @strongify(self)
        if (ret) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self savaCacheDataSource:obj];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCProgressHUD showErrorWithStatus:obj duration:1.5];
            });
        }
    }];
     [DFCSyllabusUtility hideActivityIndicator];
}

//登录成功本地缓存数据
-(void)savaCacheDataSource:(NSDictionary*)obj{
    [[NSUserDefaultsManager shareManager]setTeacherInfoCache:obj];
    [[NSUserDefaultsManager shareManager]setAccounNumber:_accountTextField.text password:_passWordField.text];
    [[NSUserDefaultsManager shareManager]saveUserToken:[obj objectForKey:@"token"]];
    [self loginHome];
}

// add by hemiying
-(NSMutableDictionary*)studentparams{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
    [params SafetySetObject:_accountTextField.text forKey:@"studentCode"];
    [params SafetySetObject:_accountTextField.text forKey:@"userCode"];
    [params SafetySetObject:[_passWordField.text md5Hash] forKey:@"password"];
    return params;
}

-(NSMutableDictionary*)params{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
    [params SafetySetObject:_accountTextField.text forKey:@"teacherCode"];
    [params SafetySetObject:_accountTextField.text forKey:@"userCode"];
    [params SafetySetObject:[_passWordField.text md5Hash] forKey:@"password"];
    return params;
}

-(void)loginHome{
    [DFCUserDefaultManager setIsLogin:YES];
    
    //开启监听
    if ([DFCUserDefaultManager getUserToken] && ![DFCUserDefaultManager isUseLANForClass]) {
        [DFCRabbitMqChatMessage startMQConnection];
        [DFCNotificationCenter postNotificationName:DFC_LOGIN_SUCCESS_NOTIFICATION object:nil];
    }
    DFCHomeViewController *controller = [[DFCHomeViewController alloc] init];
    [DFCEntery switchToHomeViewController:controller];
    
    [DFCUserDefaultManager setIsUseLANForClass:NO];
}


-(void)redactPassWord:(DFCTPassWordField *)redactPassWord code:(UIButton *)code{
    [UIView animateWithDuration:showtime animations:^{
        _clarityView.hidden = NO;
    }];
}

-(void)deleteBackward{
    if ([_passWordField.text isEqualToString:@""]){
        [UIView animateWithDuration:showtime animations:^{
            _clarityView.hidden = NO;
        }];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField==_passWordField) {
        [_passWordField textFieldDidEndEditing];
        return;
    }
    if (_accountTextField==textField) {
        DEBUG_NSLog(@"remove");
        // comment by hmy
        // [[NSUserDefaultsManager shareManager]removeAccounNumber];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==_passWordField) {
        [_passWordField textFieldBeginEditing];
    }
    if (_accountTextField==textField) {
        _accountTextField.text = textField.text;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_accountTextField resignFirstResponder];
    if (textField==_passWordField) {
        [_passWordField resignFirstResponder];
        if ([[NSUserBlankSimple shareBlankSimple]isBlankString:_passWordField.text]==NO) {
            [self login:self.login];
        }
    }
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    NSString *toBeString=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if (_passWordField==textField) {
        [_passWordField textFieldBeginEditing];
        if (string.length>0) {
            [UIView animateWithDuration:showtime animations:^{
                _clarityView.hidden = YES;
            }];
        }
        if ([toBeString length]>18) {
            return NO;
        }
    }
    
    return YES;
}

-(NSString*)getAccounNumber{
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    return account;
}
-(NSString *)getPassWord{
    NSString *password = [[NSUserDefaultsManager shareManager]getPassWord];
    return password;
}

@end

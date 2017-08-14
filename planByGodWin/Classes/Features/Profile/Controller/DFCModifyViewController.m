//
//  DFCModifyViewController.m
//  planByGodWin
//
//  Created by zeros on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCModifyViewController.h"
#import "DFCProfileSelectCell.h"
#import "DFCProfileSelectInfo.h"
#import "DFCProfileInfo.h"
#import "DFCStudentModel.h"

#import "DFCStudentModel.h"

@interface DFCModifyViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITextField *field;
@property (nonatomic, weak) UITextField *repeatField;
@property (nonatomic, weak) UIButton *cancelButton;
@property (nonatomic, weak) UIButton *confirmButton;
@property (nonatomic, weak) UITableView *selectView;

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, copy) void(^confirmFun)(NSString *newInfo);
@property (nonatomic, copy) NSArray *selectInfoList;
@property (nonatomic, weak) DFCProfileInfo *info;

@property (nonatomic, weak) DFCStudentModel *studentInfo;

@end

@implementation DFCModifyViewController

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath info:(DFCProfileInfo *)info
{
    if (self = [super init]) {
        self.row = indexPath.row;
        self.info = info;
    }
    return self;
}

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath studentInfo:(DFCStudentModel *)info{
    if (self = [super init]) {
        self.row = indexPath.row;
        self.studentInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    DEBUG_NSLog(@"%@");
    
    if (_row == 0 || _row == 1 || _row == 3 || _row == 4) {
        [self initAllViewsForModify];
    } else {
        [self initAllViewsForSelect];
        [self requestInfoForSelect];
    }
    
    [self initActions];
    // Do any additional setup after loading the view.
}

- (void)requestInfoForSelect
{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    if (_row == 7) {
//        [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"code"];
//        [[HttpRequestManager sharedManager] requestGetWithPath:URL_GetTeacherSubject params:params completed:^(BOOL ret, id obj) {
//        
//        }];
//    } else {
//        [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
//        [[HttpRequestManager sharedManager] requestGetWithPath:URL_ClassList params:params completed:^(BOOL ret, id obj){
//            if (ret) {
//                self.selectInfoList = [DFCProfileSelectInfo ModelListWithInfo:obj type:DFCProfileSelectInfoTypeClass];
//                [DFCProfileSelectInfo ModelList:self.selectInfoList MergeInfoList:self.info.classes];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.selectView reloadData];
//                });
//            }
//        }];
//    }
}

- (void)initActions
{
    if (_row == 0 || _row == 1 || _row == 3 || _row == 4) {
        [_confirmButton addTarget:self action:@selector(confirmModifyAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_confirmButton addTarget:self action:@selector(confirmSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)confirmSelectAction:(UIButton *)sender
{
    
}

- (void)confirmModifyAction:(UIButton *)sender
{
    if (_row != 3) {
        if (_row == 4) {
            NSString *pattern1 = @"^1+[3578]+\\d{9}";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern1];
            BOOL isMatch = [pred evaluateWithObject:_field.text];
            if (!isMatch) {
                [DFCProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1.0f];
                return;
            }
        }
        if (_row == 0) {
            NSString *pattern1 = @"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern1];
            BOOL isMatch = [pred evaluateWithObject:_field.text];
            if (!isMatch) {
                [DFCProgressHUD showErrorWithStatus:@"请输入有效的IP地址" duration:1.0f];
                return;
            }
        }
        _confirmFun(_field.text);
    } else {
        if ([_field.text isEqualToString:_repeatField.text]) {
            NSString *pattern2 = @"\\d{6}";//@"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,18}";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern2];
            BOOL isMatch = [pred evaluateWithObject:_field.text];
            if (!isMatch) {
                [DFCProgressHUD showErrorWithStatus:@"请输入正确格式的密码" duration:1.0f];
                return;
            } else {
                if (self.info) {
                    [self requestModifyPassword];
                    
                }else if (self.studentInfo){
                    [self modifyStudentPsd];
                }
            }
        } else {
            [DFCProgressHUD showErrorWithStatus:@"两次密码输入不一致" duration:1.0f];
            return;
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)requestModifyPassword
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:[_field.text md5Hash]  forKey:@"password"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ModifyTeacherPsw params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            [DFCProgressHUD showSuccessWithStatus:@"修改密码成功" duration:1.5f];
        } else {
            [DFCProgressHUD showErrorWithStatus:@"修改密码失败" duration:1.5f];
        }
    }];
}

// 修改学生密码
- (void)modifyStudentPsd{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    DEBUG_NSLog(@"studentCode---%@",[DFCUserDefaultManager getSchoolCode]);
    
    NSString *token = [DFCUserDefaultManager getUserToken];
    
    [params SafetySetObject:[DFCUserDefaultManager currentCode] forKey:@"studentCode"];
    [params SafetySetObject:[_field.text md5Hash]  forKey:@"password"];
    [params SafetySetObject:token forKey:@"token"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ModifyStudentPsw params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            
            [DFCProgressHUD showSuccessWithStatus:@"修改密码成功" duration:1.5f];
        } else {
            DEBUG_NSLog(@"修改密码失败---%@",obj);
            [DFCProgressHUD showErrorWithStatus:@"修改密码失败" duration:1.5f];
        }
    }];
}

- (void)confirmModify:(void (^)(NSString *))block
{
    self.confirmFun = block;
}

- (void)initAllViewsForSelect
{
    UITableView *selectView = [[UITableView alloc] init];
    selectView.dataSource = self;
    selectView.delegate = self;
    selectView.bounces = NO;
    [selectView registerNib:[UINib nibWithNibName:@"DFCProfileSelectCell" bundle:nil] forCellReuseIdentifier:@"selectCell"];
    [self.view addSubview:selectView];
    self.selectView = selectView;
    [selectView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsMake(10, 10, 60, 10));
    }];
    
//    UIButton *button1 = [[UIButton alloc] init];
//    [button1 setTitle:@"确认" forState:UIControlStateNormal];
//    [button1 setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
//    [self.view addSubview:button1];
//    self.confirmButton = button1;
//    [button1 makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).offset(-10);
//        make.left.equalTo(self.view);
//        make.right.equalTo(self.view);
//        make.top.equalTo(selectView.bottom).offset(10);
//    }];
}



- (void)initAllViewsForModify
{
    UITextField *field1 = [[UITextField alloc] init];
    field1.text = [_info infoForIndex:_row];
    field1.textAlignment = NSTextAlignmentCenter;
    field1.clearsOnBeginEditing = YES;
    [self.view addSubview:field1];
    self.field = field1;
    [field1 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        if (_row == 3) {
            make.height.equalTo(self.view).multipliedBy(0.333);
        } else {
            make.height.equalTo(self.view).multipliedBy(0.5);
        }
        
    }];
    UITextField *field2 = nil;
    if (_row == 4) {
        field1.keyboardType = UIKeyboardTypePhonePad;
    } else if (_row == 3) {
        field1.secureTextEntry = YES;
        field1.keyboardType = UIKeyboardTypeASCIICapable;
        field1.placeholder = @"密码";
        field2 = [[UITextField alloc] init];
        field2.secureTextEntry = YES;
        field2.keyboardType = UIKeyboardTypeASCIICapable;
        field2.placeholder = @"重复密码";
        field2.textAlignment = NSTextAlignmentCenter;
        field2.clearsOnBeginEditing = YES;
        [self.view addSubview:field2];
        self.repeatField = field2;
        [field2 makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(field1.bottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.equalTo(field1);
        }];
    }
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line1];
    [line1 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(field1.bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(0.5);
    }];
    
    UIView *line2 = nil;
    if (_row == 3) {
        line2 = [[UIView alloc] init];
        line2.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:line2];
        [line2 makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(field2.bottom);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.equalTo(0.5);
        }];
    }
    
    UIButton *button1 = [[UIButton alloc] init];
    [button1 setTitle:@"取消修改" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:button1];
    self.cancelButton = button1;
    UIButton *button2 = [[UIButton alloc] init];
    [button2 setTitle:@"确认修改" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.view addSubview:button2];
    self.confirmButton = button2;
    UIView *line3 = [[UIView alloc] init];
    line3.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line3];
    [button1 makeConstraints:^(MASConstraintMaker *make) {
        if (_row == 3) {
            make.top.equalTo(line2.bottom);
        } else {
            make.top.equalTo(line1.bottom);
        }
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(line3.left);
        make.width.equalTo(button2);
    }];
    [line3 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1);
        make.bottom.equalTo(button1);
        make.left.equalTo(button1.right);
        make.right.equalTo(button2.left);
        make.width.equalTo(0.5);
    }];
    [button2 makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1);
        make.bottom.equalTo(self.view);
        make.left.equalTo(line3.right);
        make.right.equalTo(self.view);
        make.width.equalTo(button1);
    }];
}


- (CGSize)preferredContentSize
{
    CGSize size = CGSizeZero;
    if (_row == 3) {
        size = CGSizeMake(300, 150);
    } else {
        size = CGSizeMake(300, 100);
    }
//    if (_row != 4 && _row != 5 && _row != 2) {
//        size = CGSizeMake(300, 600);
//    }
    return size;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCProfileSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell" forIndexPath:indexPath];
    [cell configWithInfo:_selectInfoList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    DFCProfileSelectInfo *info = self.selectInfoList[indexPath.row];
    if (_row == 7) {
        
    } else {
        [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"code"];
        [params SafetySetObject:info.code forKey:@"classCode"];
        [params SafetySetObject:@"02" forKey:@"roleType"];
        NSString *path = nil;
        if (info.isSelected) {
//            path = URL_QuitClass;
        } else {
//            path = URL_JoinClass;
        }
        
        [[HttpRequestManager sharedManager] requestPostWithPath:path params:params completed:^(BOOL ret, id obj){
            if (ret) {
                [DFCProgressHUD showSuccessWithStatus:[obj objectForKey:@"msg"] duration:1.5f];
                info.isSelected  = !info.isSelected;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.selectView reloadData];
                });
                self.confirmFun(nil);
            } else {
                [DFCProgressHUD showErrorWithStatus:[obj objectForKey:@"msg"] duration:1.5f];
            }
        }];
    }
}



@end

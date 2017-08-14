//
//  DFCGrouplistViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGrouplistViewController.h"
#import "DFCGroupClassView.h"
#import "NSUserDataSource.h"
@interface DFCGrouplistViewController ()
@property(nonatomic,copy)NSString*classCode;
@property(nonatomic,copy)NSString*className;
@property(nonatomic,strong)DFCGroupClassView *classView;
@end

@implementation DFCGrouplistViewController
-(instancetype)initWithMsgClassCode:(NSString *)classCode className:(NSString *)className{ 
    if (self = [super init]) {
        _classCode = classCode;
        _className = className;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self classView];
}

-(DFCGroupClassView*)classView{
    if (!_classView) {
        CGFloat classViewWidth =self.view.frame.size.width-100;
        _classView = [DFCGroupClassView initWithDFCGroupClassViewFrame:CGRectMake((self.view.frame.size.width-classViewWidth)/2, 130, classViewWidth, 375) className:_className teacher:nil president:nil ClassCode:_classCode];
        [self.view addSubview:_classView];
    }
    return _classView;
}

-(void)setNavigationViw{
    [super setNavigationViw];
}
-(void)setNavigationrightItem{
    [super setNavigationrightItem];
    [self.rightItem setImage:[UIImage imageNamed:@"Board_Back"] forState:UIControlStateNormal];
}


-(void)setNavigationleftItem{
    [super setNavigationleftItem];
    if (![[NSUserDefaultsManager shareManager]isUserMark]) {
        [self.leftItem setTitle:@"退出班级" forState:UIControlStateNormal];
        [self.leftItem setKey:SubkeyUserName];
    }

}
#pragma mark-退出班级
-(void)pushViewItem:(DFCButton *)sender{
    @weakify(self)
    KDBlockAlertView *alertView = [[KDBlockAlertView alloc] initWithTitle:@"确认退出班级？" message:@"" block:^(NSInteger buttonIndex) {
        @strongify(self)
        if (buttonIndex == 0) {
            return;
        } else if (buttonIndex == 1) {
            [self justLogout];
        }
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"];
    [alertView show];
    
}
- (void)justLogout {
    //退出班级
    [self sendNetworkClass];
}

#pragma mark-教师加入所教班级列表
-(void)sendNetworkClass{
    NSMutableDictionary  *params  =  [[NSMutableDictionary alloc] initWithCapacity:1];
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    //01 班主任，02任课老师 String Y
    [params SafetySetObject:_classCode forKey:@"classCode"];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:dic[@"token"] forKey:@"token"];
    [params SafetySetObject:dic[@"teacherInfo"][@"teacherCode"] forKey:@"teacherCode"];
    
    [[HttpRequestManager sharedManager]requestPostWithPath:@"class/exitteacher"   params: params completed:^(BOOL ret, id obj) {
        
        if (ret) {
            
            if (self.succeed) {
                self.succeed();
            }
            [DFCProgressHUD showErrorWithStatus:@"退出班级成功" duration:1.5];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [DFCProgressHUD showErrorWithStatus:obj duration:1.5];
        }
    }];
    
    
}

-(void)popViewItem:(DFCButton *)sender{
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

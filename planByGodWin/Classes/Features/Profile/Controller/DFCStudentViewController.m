//
//  DFCStudentViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCStudentViewController.h"
#import "DFCProfileInfoCell.h"
#import "DFCModifyViewController.h"
#import "DFCProfileInfo.h"
#import "DFCEntery.h"
#import "NSUserDefaultsManager.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCStudentModel.h"
@interface DFCStudentViewController ()<UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, JSImagePickerViewControllerDelegate>

@property (nonatomic, weak) UITableView *profileTableView;
@property (nonatomic, strong) DFCStudentModel *model ;
@end

@implementation DFCStudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllViews];
    [self initData];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.profileTableView reloadData];
}

- (void)dealloc {
    DEBUG_NSLog(@"DFCStudentViewController---dealloc");
}

- (void)initData{
    [self requestPersonalInfo];
}

- (void)initAllViews{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.text = @"学生个人中心";
    [self.view addSubview:titleLabel];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
    }];
    
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutButton setBackgroundColor:kUIColorFromRGB(ButtonRedColor)];
    [logoutButton addTarget:self action:@selector(loginOut:) forControlEvents:UIControlEventTouchUpInside];
    logoutButton.layer.cornerRadius = 5;
    logoutButton.clipsToBounds = YES;
    [self.view addSubview:logoutButton];
    [logoutButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.4);
        make.height.equalTo(44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20);
    }];
    
    UITableView *profileTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    profileTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    profileTable.dataSource = self;
    profileTable.delegate = self;
    profileTable.bounces = NO;
    profileTable.showsVerticalScrollIndicator = NO;
//    profileTable.bounces = NO;
    [profileTable registerNib:[UINib nibWithNibName:@"DFCProfileInfoCell" bundle:nil] forCellReuseIdentifier:@"profileCell"];
    [self.view addSubview:profileTable];
    self.profileTableView = profileTable;
    [profileTable makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.bottom).offset(20);
        make.bottom.equalTo(logoutButton.top).offset(-20);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
}


- (void)loginOut:(UIButton *)sender{
    //清除个人信息数据缓存
    [[NSUserDefaultsManager shareManager]removeAllInfo];
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    if (dic==nil||[dic count]==0) {
        [self dismissViewControllerAnimated:YES completion:^{
            [DFCUserDefaultManager setIsLogin:NO];
            [[NSUserDefaultsManager shareManager]removePassWord];
            // 断开mq连接
            [DFCRabbitMqChatMessage closeMQConnection];
            //回到登陆页面
            [DFCEntery switchToLoginViewController];
            NSDate *date = [NSDate date];
            DEBUG_NSLog(@"%@time%@", date, [DFCUserDefaultManager getUserToken]);
        }];
    }
}

-(NSMutableDictionary*)params{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    [params SafetySetObject:dic[@"studentInfo"][@"studentCode"] forKey:@"userCode"];
    [params SafetySetObject:dic[@"token"] forKey:@"token"];
    [params SafetySetObject:dic[@"studentInfo"][@"studentCode"]  forKey:@"studentCode"];
    return params;
}

- (void)requestPersonalInfo{
    NSDictionary *info = [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    self.model = [DFCStudentModel jsonWithObj:info];
    [self.profileTableView reloadData];
}


#pragma mark <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCProfileInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    [cell studentIndexPath:indexPath model:self.model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.bounds.size.height / 10;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(500, 700);
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DFCProfileInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.canEdit) {
        
        DFCModifyViewController *modifyController = [[DFCModifyViewController alloc] initWithIndexPath:indexPath studentInfo:self.model];
        modifyController.modalPresentationStyle = UIModalPresentationPopover;
        modifyController.popoverPresentationController.sourceView = cell;
        modifyController.popoverPresentationController.sourceRect = cell.contentFrame;
        modifyController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionRight;
        modifyController.popoverPresentationController.backgroundColor = [UIColor whiteColor];
        modifyController.popoverPresentationController.delegate = self;
        
        
        [self presentViewController:modifyController animated:YES completion:nil];
    }
    
    if (indexPath.row==0) {
        JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
        imagePicker.delegate = self;
        [imagePicker showImagePickerInController:self animated:YES];
    }
}
- (void)imagePickerDidSelectImage:(UIImage *)image url:(NSURL *)fileUrl{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    [[HttpRequestManager sharedManager] upLoadImageHead:fileUrl cacheImage:image params:params completed:^(BOOL ret, id obj) {
        if (ret) {
           [self updateUrl:obj];
        } else {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [DFCProgressHUD showSuccessWithStatus:obj[@"msg"] duration:2];
            }
            else{
                [DFCProgressHUD showSuccessWithStatus:obj duration:2];
            }
        }
    }];
}

- (void)updateUrl:(NSString *)url{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    [params SafetySetObject:dic[@"studentInfo"][@"studentCode"] forKey:@"userCode"];
    [params SafetySetObject:dic[@"token"] forKey:@"token"];
    [params SafetySetObject:dic[@"studentInfo"][@"studentCode"]  forKey:@"studentCode"];
    [params SafetySetObject: url forKey:@"imgUrl"];
    DEBUG_NSLog(@"%@",[self params]);
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_UpdateStudent params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            [DFCProgressHUD showSuccessWithStatus:@"修改个人信息成功" duration:1.5f];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCUserDefaultManager setStudentIcon:url];
                [DFCNotificationCenter postNotificationName:DFC_PROFILE_CHANGEHEADIMAGE_NOTIFICATION object:nil];
//                [self requestPersonalInfo];
            });
        } else {
            [DFCProgressHUD showErrorWithStatus:@"修改个人信息失败" duration:1.5f];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

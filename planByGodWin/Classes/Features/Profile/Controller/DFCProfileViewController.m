//
//  DFCProfileViewController.m
//  planByGodWin
//
//  Created by zeros on 16/12/29.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCProfileViewController.h"
#import "DFCProfileInfoCell.h"
#import "DFCModifyViewController.h"
#import "DFCProfileInfo.h"
#import "DFCEntery.h"
#import "NSUserDefaultsManager.h"
#import "DFCRabbitMqChatMessage.h"

@interface DFCProfileViewController ()<UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, JSImagePickerViewControllerDelegate>


@property (nonatomic, weak) UITableView *profileTableView;

@property (nonatomic, strong) DFCProfileInfo *profileInfo;

@end

@implementation DFCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllViews];
    [self initData];
    [DFCNotificationCenter addObserver:self selector:@selector(reloadProfileTable:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)dealloc
{
    [DFCNotificationCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.profileTableView reloadData];
}

- (void)initData
{
    [self requestPersonalInfo];
}

- (void)initAllViews
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.text = @"个人中心";
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
    [profileTable registerNib:[UINib nibWithNibName:@"DFCProfileInfoCell" bundle:nil] forCellReuseIdentifier:@"profileCell"];
    [self.view addSubview:profileTable];
    self.profileTableView = profileTable;
    [profileTable makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.bottom).offset(20);
        make.height.equalTo(520);
//        make.bottom.equalTo(logoutButton.top).offset(-20);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
}


- (void)loginOut:(UIButton *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        //清除个人信息数据缓存
        [DFCUserDefaultManager setIsLogin:NO];
        [[NSUserDefaultsManager shareManager]removeAllInfo];
        [[NSUserDefaultsManager shareManager]removePassWord];
        if ( [[NSUserBlankSimple shareBlankSimple]isBlankString:[[NSUserDefaultsManager shareManager]getPassWord]]==YES) {
            // 断开mq连接
            [DFCRabbitMqChatMessage closeMQConnection];
            [self dismissViewControllerAnimated:YES completion:^{
                //回到登陆页面
                [DFCEntery switchToLoginViewController];
                DEBUG_NSLog(@"%@",[[NSUserDefaultsManager shareManager]getPassWord]);
            }];
        }
    });
}

- (void)requestPersonalInfo{
    NSDictionary *info = [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    self.profileInfo = [[DFCProfileInfo alloc] initWithInfo:info];
    [self.profileTableView reloadData];
}

- (void)requestModifyPersonalInfo
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params addEntriesFromDictionary:_profileInfo.baseInfo];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_UpdateUserInfo params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            [DFCProgressHUD showSuccessWithStatus:@"修改个人信息成功" duration:1.5f];
            [self requestPersonalInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCNotificationCenter postNotificationName:DFC_PROFILE_CHANGEHEADIMAGE_NOTIFICATION object:nil];
//                [_profileTableView reloadData];
            });
        } else {
            [DFCProgressHUD showErrorWithStatus:@"修改个人信息失败" duration:1.5f];
        }
        
    }];

}

- (void)reloadProfileTable:(NSNotification *)notificaation
{
//    [self.profileTableView reloadData];
}


#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCProfileInfoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.canEdit) {
        if (indexPath.row == 6) {  // 进入支付管理
            DEBUG_NSLog(@"进入支付管理");
        }else {     // 修改
            DFCModifyViewController *modifyController = [[DFCModifyViewController alloc] initWithIndexPath:indexPath info:self.profileInfo];
            modifyController.modalPresentationStyle = UIModalPresentationPopover;
            modifyController.popoverPresentationController.sourceView = cell;
            modifyController.popoverPresentationController.sourceRect = cell.contentFrame;
            modifyController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionRight;
            modifyController.popoverPresentationController.backgroundColor = [UIColor whiteColor];
            modifyController.popoverPresentationController.delegate = self;
            @weakify(self)
            [modifyController confirmModify:^(NSString *newInfo) {
                @strongify(self)
                [self.profileInfo modifyInfoForIndexPath:indexPath newInfo:newInfo];
                [self requestModifyPersonalInfo];
            }];
            [self presentViewController:modifyController animated:YES completion:^{
            }];
        }
    }
    if (indexPath.row == 0) {
        JSImagePickerViewController *imagePicker = [[JSImagePickerViewController alloc] init];
        imagePicker.delegate = self;
        [imagePicker showImagePickerInController:self animated:YES];
    }
}

#pragma mark <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCProfileInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
    [cell configWithIndexPath:indexPath profileInfo:_profileInfo];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.bounds.size.height / 8;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(500, 700);
}

- (void)imagePickerDidSelectImage:(UIImage *)image url:(NSURL *)fileUrl
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    [[HttpRequestManager sharedManager] upLoadImageHead:fileUrl cacheImage:image params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            [self syncHeadImageUrl:obj];
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

- (void)syncHeadImageUrl:(NSString *)url
{
    self.profileInfo.headImageUrl = url;
    [self requestModifyPersonalInfo];
}

@end

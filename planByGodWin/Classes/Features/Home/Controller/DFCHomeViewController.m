//
//  DFCHomeViewController.m
//  planByGodWin
//
//  Created by zeros on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCHomeViewController.h"
#import "DFCHomeFunctionView.h"
#import "DFCProfileViewController.h"
#import "DFCSettingViewController.h"
#import "DFCCoursewareListController.h"
#import "SMTabbedSplitViewController.h"
#import "DFCTemporaryDownloadViewController.h"
#import "DFCSeatsLayoutController.h"
#import "DFCStudentViewController.h"
#import "DFCEntery.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCProfileInfo.h"
#import "UIButton+WebCache.h"
#import "DFCProfileButton.h"
#import "DFCStudentModel.h"
#import "DFCBoardCareTaker.h"
#import "AppDelegate.h"
#import "DFCCoursewareListController.h"
#import "DFCCloudFileListController.h"
#import "HandoverScreenViewController.h"
#import "DFCShareYHController.h"
#import "DFCShareStoreViewController.h" // 云盘

static CGFloat  margin = 15.0;
static CGFloat  width = 326.0;
static CGFloat  height = 260.0;

@interface DFCHomeViewController ()<UIPopoverPresentationControllerDelegate>
@property (nonatomic, weak) DFCHomeFunctionView *myCourseware;
@property (nonatomic, weak) DFCHomeFunctionView *myClass;
@property (nonatomic, weak) DFCHomeFunctionView *shareStore;
@property (nonatomic, weak) DFCHomeFunctionView *dfcCloud;

@property (nonatomic, weak) DFCProfileButton *profileButton;
@property (nonatomic, weak) UIButton *setButton;
@property (nonatomic, weak) DFCStudentViewController *studentVC;
@property (nonatomic, weak) DFCProfileViewController *teacherVC;
@property (nonatomic, weak) DFCSettingViewController*setVC;
@end

@implementation DFCHomeViewController

- (void)dealloc {
    DEBUG_NSLog(@"DFCHomeViewController dealloc");
    // comment by hmy
    // [[NSNotificationCenter defaultCenter] postNotificationName:MQOFlineMsg object:nil];
    [DFCNotificationCenter removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // add by 何米颖
    // 打开未保存文件
    NSString *token = [[NSUserDefaultsManager shareManager] getUserToken];
    
    if ([[DFCBoardCareTaker sharedCareTaker] hasTempFile] && token != nil) {
        DFCCoursewareListController *coursewareController = [[DFCCoursewareListController alloc] init];
        
        AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
        UINavigationController *navi = (UINavigationController *)appDelegate.window.rootViewController;
        [navi pushViewController:coursewareController animated:YES];
        navi.navigationBar.hidden = NO;
        
        [coursewareController openTempBoard];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_studentVC dismissViewControllerAnimated:YES completion:nil];
    [_teacherVC dismissViewControllerAnimated:YES completion:nil];
    [_setVC dismissViewControllerAnimated:YES completion:nil];
    
    // add by gyh 界面消失时，将界面中的presentedvc 进行dismiss
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBar.hidden=YES;
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)msgOFline:(NSNotification *)note{
    // modify by hmy
    NSString *user = [note object];
    NSString *token = [[NSUserDefaultsManager shareManager]getUserToken];
    
    if (![token isEqualToString:user] &&
        user!=nil &&
        token!=nil) {
        DFCLogoutCommand *logoutCmd = [DFCLogoutCommand new];
        [DFCCommandManager excuteCommand:logoutCmd
                           completeBlock:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //注册消息提示显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgOFline:) name:MQOFlineMsg  object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(updateProfileButton) name:DFC_PROFILE_CHANGEHEADIMAGE_NOTIFICATION object:nil];
    [self initAllViews];
    [self initActions];
//    [self updateProfileButton];
    [self loadPersonInfo];
}

/**
 加载个人信息
 */
- (void)loadPersonInfo{
    // 从登陆缓存信息中获取
    NSDictionary *infoDic = [[NSUserDefaultsManager shareManager] getTeacherInfoCache];
     if ([DFCUtility isCurrentTeacher]) {   // 教师
         DFCProfileInfo *info = [[DFCProfileInfo alloc] initWithInfo:infoDic];
         NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, info.headImageUrl];
         [_profileButton.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
         [_profileButton setTitleLabelName:info.name];
     }else {    // 学生
         DFCStudentModel *info = [DFCStudentModel jsonWithObj:infoDic];
         NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, info.imgUrl];
         [_profileButton.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
         [_profileButton setTitleLabelName:info.name];
     }
}

#pragma mark - 个人中心按钮头像名字显示
-  (void)updateProfileButton{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *url = nil;
    if ([DFCUtility isCurrentTeacher]) {
        [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
        url = URL_UserInfo;
    } else {
        NSDictionary *dic= [[NSUserDefaultsManager shareManager] getTeacherInfoCache];
        [params SafetySetObject:dic[@"studentInfo"][@"studentCode"]  forKey:@"studentCode"];
        url = URL_StudentInfo;
    }
    //    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            
            [[NSUserDefaultsManager shareManager]setTeacherInfoCache:obj];  // 保存用户信息
            if ([DFCUtility isCurrentTeacher]) {
                DFCProfileInfo *info = [[DFCProfileInfo alloc] initWithInfo:obj];
                dispatch_async(dispatch_get_main_queue(), ^{
                    DEBUG_NSLog(@"Teacher===info===%@",info.name);
                    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, info.headImageUrl];
                    [_profileButton.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
                    [_profileButton setTitleLabelName:info.name];
                    
                    if (_teacherVC) {
                        [_teacherVC requestPersonalInfo];
                    }
                });
            } else {
                DFCStudentModel *info = [DFCStudentModel jsonWithObj:obj];
                DEBUG_NSLog(@"Student===info===%@",info.name);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, info.imgUrl];
                    [_profileButton.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
                    [_profileButton setTitleLabelName:info.name];
                    if (_studentVC) {
                        [_studentVC requestPersonalInfo];
                    }
                });
            }
        } else {
                [DFCProgressHUD showErrorWithStatus:@"获取个人信息失败" duration:1.5f];
        }
    }];
}

#pragma mark-我的信息点击
- (void)profileButtonAction:(UIButton *)sender{
    if ([[NSUserDefaultsManager shareManager]isUserMark]) {//学生登陆
         DFCStudentViewController *controller = [[DFCStudentViewController alloc] init];
        _studentVC = controller;
         [self presentController:controller sender:sender];
        
    }else{//教师登陆
     DFCProfileViewController *controller = [[DFCProfileViewController alloc] init];
        _teacherVC = controller;
        [self presentController:controller sender:sender];
    }
}

- (void)setButtonAction:(UIButton *)sender{
    
    DFCSettingViewController *controller = [[DFCSettingViewController alloc] init];
    _setVC = controller;
    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.imageView.frame;
    controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    controller.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    controller.popoverPresentationController.delegate = self;
    [self presentViewController:controller animated:YES completion:^{
    }]; 
}

-(void)presentController:(UIViewController*)controller sender:(UIButton *)sender{
    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.frame;
    controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
     controller.popoverPresentationController.backgroundColor = [UIColor whiteColor];
     controller.popoverPresentationController.delegate = self;
     [self presentViewController:controller animated:YES completion:^{
    }];

}
- (void)initActions{
    [self.profileButton.tapButton addTarget:self action:@selector(profileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.setButton addTarget:self action:@selector(setButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    @weakify(self)
    self.myCourseware.tapFun = ^() {
        @strongify(self)
        DFCCoursewareListController *coursewareController = [[DFCCoursewareListController alloc] init];
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:coursewareController animated:YES];
        
    };
    self.myClass.tapFun = ^() {
        @strongify(self)
       SMTabbedSplitViewController*split=[[SMTabbedSplitViewController alloc] initTabbedSplit];
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:split animated:YES];
    };
    
    self.shareStore.tapFun = ^() {
        @strongify(self)
        DFCShareYHController *share = [[DFCShareYHController alloc]init];
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:share animated:YES];
    };
    
    self.dfcCloud.tapFun = ^(){
        @strongify(self)
        DFCShareStoreViewController *cloudVC = [[DFCShareStoreViewController alloc]init];
        cloudVC.sourceType = DFCSourceFromHome;
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:cloudVC animated:YES];
    };
}

- (void)firstVersion{
    DFCHomeFunctionView *view1 = [[DFCHomeFunctionView alloc] initWithImage:[UIImage imageNamed:@"home_mycourseware"] title:@"我的课件"];
    [self.view addSubview:view1];
    self.myCourseware = view1;
    
    DFCHomeFunctionView *view2 = [[DFCHomeFunctionView alloc] initWithImage:[UIImage imageNamed:@"home_myclass"] title:@"我的班级"];
    [self.view addSubview:view2];
    self.myClass = view2;
    
    [self.myClass makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(width, height));
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view).offset(width/2+margin);
    }];
    
    [self.myCourseware makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(width, height));
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view).offset(-margin-width/2);
    }];
}

- (void)vistorVersion {
    DFCHomeFunctionView *view1 = [[DFCHomeFunctionView alloc] initWithImage:[UIImage imageNamed:@"home_mycourseware"] title:@"我的课件"];
    [self.view addSubview:view1];
    self.myCourseware = view1;
    
    [self.myCourseware makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(width, height));
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
}

- (void)secondVersion{
    DFCHomeFunctionView *view1 = [[DFCHomeFunctionView alloc] initWithImage:[UIImage imageNamed:@"home_mycourseware"] title:@"我的课件"];
    [self.view addSubview:view1];
    self.myCourseware = view1;
    
    DFCHomeFunctionView *view2 = [[DFCHomeFunctionView alloc] initWithImage:[UIImage imageNamed:@"home_myclass"] title:@"我的班级"];
    [self.view addSubview:view2];
    self.myClass = view2;
    
    DFCHomeFunctionView *shareStore = [[DFCHomeFunctionView alloc] initWithImage:[UIImage imageNamed:@"home_shareStore"] title:DFCShareStoreTitle];
    [self.view addSubview:shareStore];
    self.shareStore = shareStore;
    
    DFCHomeFunctionView *dfcCloud = [[DFCHomeFunctionView alloc] initWithImage:[UIImage imageNamed:@"home_cloud"] title:@"我的云盘"];
    [self.view addSubview:dfcCloud];
    self.dfcCloud = dfcCloud;
    
    [self.myClass makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(width, height));
        make.centerY.equalTo(self.view).offset(-height/2-margin/2);
        make.centerX.equalTo(self.view).offset(width/2+margin/2);
    }];
    
    [self.myCourseware makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(width, height));
        make.centerY.equalTo(self.view).offset(-height/2-margin/2);
        make.centerX.equalTo(self.view).offset(-margin/2-width/2);
    }];
    
    [self.shareStore makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(width, height));
        make.centerY.equalTo(self.view).offset(height/2 + margin/2);
        make.centerX.equalTo(self.view).offset(-margin/2-width/2);
    }];
    
    [self.dfcCloud makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(width, height));
        make.centerY.equalTo(self.view).offset(height/2 + margin/2);
        make.centerX.equalTo(self.view).offset(margin/2 + width/2);
    }];
}
 
- (void)initAllViews
{
    self.navigationItem.title = @"主页";

    // modify by hmy
     [self secondVersion];
//    [self firstVersion];

    UIImageView *bottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_bg1"]];
    [bottomView sizeToFit];
    [self.view addSubview:bottomView];
    [bottomView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setImage:[UIImage imageNamed:@"home_set"] forState:UIControlStateNormal];
    [button2 setTitle:@"设置" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button2.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:button2];
    self.setButton = button2;
    [button2 makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(100, 44));
        make.top.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-20);
    }];
    [button2.imageView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(button2);
    }];
    [button2.titleLabel updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(button2);
    }];
    
//    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button1 setImage:[UIImage imageNamed:@"home_profile"] forState:UIControlStateNormal];
//    [button1 setTitle:@"我" forState:UIControlStateNormal];
//    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    button1.titleLabel.textAlignment = NSTextAlignmentCenter;
    DFCProfileButton *button1 = [[[NSBundle mainBundle] loadNibNamed:@"DFCProfileButton" owner:nil options:nil] firstObject];
//    CGFloat imageTopInset = (button1.frame.size.height - button1.imageView.frame.size.height) / 2;
//    CGFloat labelTopInset = (button1.frame.size.height - button1.titleLabel.frame.size.height) / 2;
//    [button1 setImageEdgeInsets:UIEdgeInsetsMake(imageTopInset, 0, imageTopInset, button1.frame.size.width - button1.imageView.frame.size.width)];
//    [button1 setTitleEdgeInsets:UIEdgeInsetsMake(labelTopInset, button1.frame.size.width - button1.titleLabel.frame.size.width, labelTopInset, 0)];
    
//    button1.backgroundColor = [UIColor redColor];
//    button1.imageView.backgroundColor = [UIColor blueColor];
//    button1.titleLabel.backgroundColor = [UIColor greenColor];
    [self.view addSubview:button1];
    self.profileButton = button1;
    [button1 makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(150, 44));
        make.top.equalTo(self.view).offset(44);
        make.right.equalTo(button2.left).offset(-20);
    }];
//    [button1.imageView updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(button1);
//    }];
//    [button1.titleLabel updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(button1);
//    }];
    
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationFullScreen;
}

@end

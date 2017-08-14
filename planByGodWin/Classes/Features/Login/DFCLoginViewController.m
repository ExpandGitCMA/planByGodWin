//
//  DFCLoginViewController.m
//  DFCEducation
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCLoginViewController.h"
#import "ElecBoardInClassViewController.h"
#import "ERSocket.h"
#import "DFCHomeViewController.h"
#import "DFCEntery.h"

#import "DFCTcpServer.h"
#import "DFCUtility.h"
#import "DFCUdpBroadcast.h"

@interface DFCLoginViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginWidth;
@property (weak, nonatomic) IBOutlet UILabel *titleName;
@property (assign,nonatomic)NSInteger win;
@end
static float const showKeyboardtime = 0.25;
@implementation DFCLoginViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=YES;
    //listen to keyboard
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(KeyboardloginShow:) name:  UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(KeyboardloginHide) name: UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark-监听键盘高度

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ERSocket sharedManager] disconnect];
    if ([[NSUserDefaultsManager shareManager]isUserMark]) {
        self.titleName.text = @"答尔问智汇课堂学生版";
    }
    if (SCREEN_WIDTH==isiPadePro_WIDTH) {
        _loginWidth.constant = 590.f;
    }
    // Do any additional setup after loading the view from its nib.
}

/*
 *@监听键盘的弹出高度信息
 */
-(void)KeyboardloginShow:(NSNotification *)notification{
    NSDictionary *userInfo =notification.userInfo;
    NSValue *rectObj = userInfo [UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [rectObj CGRectValue];
    CGRect  viewFrame = self.view.frame;
    DEBUG_NSLog(@"userInfo==%f",keyboardFrame.size.height);

    viewFrame.origin.y = -CGRectGetHeight(keyboardFrame)/2-_win;
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:0.95 initialSpringVelocity:0 options:0 animations:^{
        self.view.frame = viewFrame;
    } completion:^(BOOL finished) {
        
    }];
}

/*
 *@监听获取键盘隐藏信息
 */
-(void)KeyboardloginHide{
    CGRect  viewFrame = self.view.frame;
    viewFrame.origin.y =-_win;
    [UIView animateWithDuration:showKeyboardtime animations:^{
        self.view.frame = viewFrame;
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)visitorLogin:(id)sender {
    DFCHomeViewController *controller = [[DFCHomeViewController alloc] init];
    [DFCEntery switchToHomeViewController:controller];
    [DFCUserDefaultManager setIsUseLANForClass:YES];
    
    // add by hmy
    [DFCUdpBroadcast broadcast];
    
    if ([DFCUtility isCurrentTeacher]) {
        [DFCTcpServer startServer];
    }
}

@end

//
//  ElecBoardDetailViewController.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/7.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "ElecBoardDetailViewController.h"

#import "DFCElecBoardView.h"
#import "DFCBoardCareTaker.h"
#import "MBProgressHUD.h"
#import "ERSocket.h"
#import "AppDelegate.h"
#import "SMTabbedSplitViewController.h"
#import "PersonInfoModel.h"
#import "NSUserDataSource.h"
#import "AirPlaySecondary.h"

@interface ElecBoardDetailViewController ()<DFCElecBoardViewDelegate>
@property (nonatomic,strong)  NSNotificationCenter *center;
@property(nonatomic,strong) UIScreen *outputScreen;
@property (nonatomic, strong)UIWindow *outputWindow;
@property (nonatomic, strong)AirPlaySecondary*airPlay;
@end

@implementation ElecBoardDetailViewController

//- (void)setupOutputScreen{
//    // Setup screen mirroring for an existing screen
//    NSArray *screens = [UIScreen screens];
//    if ([screens count] > 1){
//        UIScreen *mainScreen = [UIScreen mainScreen];
//        for (UIScreen *aScreen in screens)
//        {
//            if (aScreen != mainScreen)
//            {
//                [self outScreen:aScreen];
//                break;
//            }
//        }
//    } else {
//        //Show Alert
//        
//    }
//}

//- (void)screenDidConnect:(NSNotification *)aNotification
//{
//    //A new screen got connected
//     [self outScreen:[aNotification object]];
//}

//- (void)screenDidDisconnect:(NSNotification *)aNotification
//{
//    //A screen got disconnected
//    [self disableMirroringOnCurrentScreen];
//}

//- (void)screenModeDidChange:(NSNotification *)aNotification
//{
//    //A screen mode changed
//    [self disableMirroringOnCurrentScreen];
//    [self outScreen:[aNotification object]];
//}

//- (void)disableMirroringOnCurrentScreen{
//    for (UIView *view in self.airPlay.subviews) {
//        [view removeFromSuperview];
//    }
//    [self.airPlay removeFromSuperview];
//    self.airPlay = nil;
//    self.outputWindow.hidden = YES;
//    self.outputWindow = nil;
//    self.outputScreen = nil;
//}

//-(void)outScreen:(UIScreen *)screen{
//    
//    _outputScreen = screen;
//    CGSize max = {0, 0};
//    UIScreenMode *maxScreenMode = nil;
//    for (UIScreenMode *nonce in _outputScreen.availableModes) {
//        if (maxScreenMode == nil || nonce.size.height > max.height || nonce.size.width > max.width) {
//            max = nonce.size;
//            maxScreenMode = nonce;
//         }
//    }
//
//    _outputScreen.currentMode = maxScreenMode;
//   _outputScreen.overscanCompensation =   UIScreenOverscanCompensationInsetApplicationFrame;
//    if (!_outputWindow) {
//        _outputWindow = [[UIWindow alloc] initWithFrame:_outputScreen.bounds];
//        _outputWindow.hidden = NO;
//        _outputWindow.backgroundColor = [UIColor orangeColor];
//        _outputWindow.layer.contentsGravity = kCAGravityResizeAspect;
//        _outputWindow.screen  = _outputScreen;
//    }
//    
//    _airPlay = [AirPlaySecondary airPlaySecondaryWithFrame:_outputWindow.bounds];
////       _airPlay.delegate = self;
//    _airPlay.coursewareModel = self.coursewareModel;
//     _airPlay.filePath = self.filePath;
//     _airPlay.openType = self.openType;
//     _airPlay.type = self.type;
//     _airPlay.teacherCode = self.teacherCode;
//    _airPlay.coursewareCode = self.coursewareCode;
//    _airPlay.classCode = self.classCode;
//    _airPlay.backgroundViewColor = _color;
//    [_airPlay hideToolBar];
//    _airPlay.recordScreenBgView.hidden = YES;
//    [_outputWindow addSubview:_airPlay];
//    _airPlay.cacheBoard = [[DFCBoardCareTaker sharedCareTaker] boardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//}


//- (DFCElecBoardView*)duplicate:(UIView*)view{
//    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
//    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
//}

- (void)viewDidLoad {
    [super viewDidLoad];

    [UIApplication sharedApplication].statusBarHidden = YES;
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"编辑";

    self.elecView = [DFCElecBoardView elecBoardViewWithFrame:self.view.bounds];
    self.elecView.delegate = self;  // 添加代理来控制工具条的显示与隐藏
//    self.elecView.index = self.index;
    self.elecView.coursewareModel = self.coursewareModel;
    self.elecView.filePath = self.filePath;
    self.elecView.openType = self.openType;
    self.elecView.type = self.type;
    self.elecView.frame = self.view.bounds;
    self.elecView.teacherCode = self.teacherCode;
    self.elecView.coursewareCode = self.coursewareCode;
    self.elecView.classCode = self.classCode;
    self.elecView.backgroundViewColor = _color;

    [self.view addSubview:self.elecView];
    if (self.board) {
        self.elecView.cacheBoard = self.board;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 80, 30);
    [btn setTitleColor:kUIColorFromRGB(ButtonGreenColor) forState:UIControlStateNormal];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 60, 30);
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
//    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"icon3"] forState:UIControlStateNormal];
    
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
}


- (void)setType:(ElecBoardType)type {
    _type = type;
    _elecView.type = type;
}

- (void)setOpenType:(kElecBoardOpenType)openType {
    _openType = openType;
    _elecView.openType = openType;
}

// 控制工具栏显示
- (void)setToolBarStatus:(BOOL)isHidden{    // 默认显示工具栏
    if (isHidden){  // 隐藏工具栏
        [self.elecView hideToolBar];
    }else { // 显示工具栏
        [self.elecView showToolBar];
    }
}


//-(void)createPageActiondidTapCreatePage:(NSUInteger)currentPageIndex lastPageIndex:(NSUInteger)lastPageIndex{
//    [_airPlay airPlayCreatePageActiondidTapCreatePage:currentPageIndex lastPageIndex:lastPageIndex];
//}
//
//-(void)didTapLastPage:(NSUInteger)currentPageIndex{
//    [_airPlay airPlayLastPageAction:currentPageIndex];
//}
//
//-(void)didTapNextPage:(NSUInteger)currentPageIndex{
//    [_airPlay airPlayNextPage:currentPageIndex];
//}
//
//-(void)playBoardSelectAtIndex:(NSIndexPath *)indexPath{
//    [_airPlay playBoardViewdidSelectIndexPath:indexPath];
//}


//- (void)listSubviewsOfView:(UIView *)view {
//    NSArray *subviews = [view subviews];
//    if ([subviews count] == 0) return;
//    for (UIView *subview in subviews) {
//        // Do what you want to do with the subview
//        DEBUG_NSLog(@"1=%@", subview);
//        [self listSubviewsOfView:subview];
//    }
//}

- (void)viewDidAppear:(BOOL)animated {
      [super viewDidAppear:animated];
}

- (void)dealloc{
    DEBUG_NSLog(@"detailVC-dealloc");
    DEBUG_NSLog(@"%@:----释放了",NSStringFromSelector(_cmd));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

//-(NSNotificationCenter*)center{
//    if (!_center) {
//        _center =  [NSNotificationCenter defaultCenter];
//    }
//    return _center;
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideTabbarDock:YES];
    [self.navigationController setNavigationBarHidden:YES];
    // 状态栏隐藏
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    //注册secondScreen
//    [[self center] addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
//    [[self center] addObserver:self selector:@selector(screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
//    [[self center] addObserver:self selector:@selector(screenModeDidChange:) name:UIScreenModeDidChangeNotification object:nil];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideTabbarDock:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [self.elecView hidesubView];
    
   // [self.elecView deallocAction];
    // 状态栏显示
//    [UIApplication sharedApplication].statusBarHidden = NO;
 
//    [[self center] removeObserver:self name:UIScreenDidConnectNotification object:nil];
//    [[self center] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
//    [[self center] removeObserver:self name:UIScreenModeDidChangeNotification object:nil];
//    [self disableMirroringOnCurrentScreen];
}


- (void)hideTabbarDock:(BOOL)flag {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.window.rootViewController isKindOfClass:[SMTabbedSplitViewController class]]) {
        SMTabbedSplitViewController *split = (SMTabbedSplitViewController *)appDelegate.window.rootViewController;
        SMMasterViewController *masterVC = (SMMasterViewController *)split.masterVC;
        SMTabBar *tabbar = (SMTabBar *)split.tabBar;
        
        if (flag) {
            [PersonInfoModel sharedManage].hideTab = @"1";
            CGRect frame = masterVC.view.frame;
            frame.origin.x = 0;
            frame.size.width = SCREEN_WIDTH;
            masterVC.view.frame = frame;
            tabbar.view.hidden = YES;
            
        } else {
            [PersonInfoModel sharedManage].hideTab = @"0";
            CGRect frame = masterVC.view.frame;
            frame.origin.x = 70;
            frame.size.width = SCREEN_WIDTH - 70;
            masterVC.view.frame = frame;
            tabbar.view.hidden = NO;
        }
    }
}

- (void)backAction {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"您尚未保存文件!是否保存?"
                                                       delegate:self
                                              cancelButtonTitle:@"不保存"
                                              otherButtonTitles:@"保存", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[DFCBoardCareTaker sharedCareTaker] removeTempFile];
    }
    if (buttonIndex == 1) {
        [[DFCBoardCareTaker sharedCareTaker] removeFinalFile];
        [[DFCBoardCareTaker sharedCareTaker] saveBoards];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 *  保存
 */
- (void)saveAction {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    //[self.elecView saveBoard:nil];
    [self.navigationController popViewControllerAnimated:YES];
    [hud hideAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

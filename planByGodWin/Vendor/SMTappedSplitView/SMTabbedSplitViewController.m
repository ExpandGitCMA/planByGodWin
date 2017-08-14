//
//  SMSplitViewController.m
//  SMSplitViewController
//
//  Created by Sergey Marchukov on 15.02.14.
//  Copyright (c) 2014 Sergey Marchukov. All rights reserved.
//
//  This content is released under the ( http://opensource.org/licenses/MIT ) MIT License.
//  Repository: https://github.com/sergik-ru/SMTabbedSplitViewController
//  Version 1.0.3
//

#import "SMTabbedSplitViewController.h"
#import "SMMasterViewController.h"
#import "SMTabBar.h"
#import "PersonInfoModel.h"
#import "IMColor.h"
#import "SMTabbedSplitVC.h"
#import "DFCUtility.h"
#import "NSUserDataSource.h"
//#import "MessgeViewController.h"
//#import "DFCChatMsgViewController.h"
//#import "DFCNavigationBar.h"
//#import "DFCMqMsgViewController.h"
//#import "DFCMqMsgChatViewController.h"
#import "DFCGodWinChatController.h"
#import "DFCGodWinPhoneController.h"
@interface SMTabbedSplitViewController () <SMTabBarDelegate> {
    
    //    SMMasterViewController *_masterVC;
    BOOL _masterIsHidden;
}
    @end

@implementation SMTabbedSplitViewController
    
#pragma mark -
#pragma mark - Inititalization

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] postNotificationName:MQUserToken object:nil];
}
- (id)init {
    return [self initTabbedSplit];
}
    
- (id)initTabbedSplit {
    self = [super init];
    if (self) {
        _tabBar = [[SMTabBar alloc] init];
        _tabBar.delegate = self;
        _masterVC = [[SMMasterViewController alloc] init];
        [self tabBarbedSplit];
    }
    
    return self;
}

-(void)tabBarbedSplit{
    self.title = @"我的班级";

    SMTabbedSplitVC* messgeSplitVC = [[SMTabbedSplitVC alloc] init];
    DFCGodWinPhoneController *phoneVC = [[DFCGodWinPhoneController alloc]init];
    DFCGodWinChatController*chatVC = [[DFCGodWinChatController alloc]initWithDFCGodWinPhoneDelegate:phoneVC];
    UINavigationController* chatNav = [[UINavigationController alloc] initWithRootViewController:chatVC];
    messgeSplitVC.detailViewController = chatNav;
    messgeSplitVC.viewControllers = @[phoneVC];
    SMTabBarItem *tab_book = [[SMTabBarItem alloc] initWithVC:messgeSplitVC  image:[UIImage imageNamed:@"tabBar_book"] andTitle:@"联系人"];
    tab_book.selectedImage = [UIImage imageNamed:@"tabBar_book_select"];
    
    self.tabsViewControllers = @[tab_book];
    self.background = [UIColor whiteColor];
}


#pragma mark-action
-(void)chatNormalItem{
    
}
-(void)dismissNormalItem{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initSplit {
    self = [super init];
    if (self) {
        _splitType = SMDefaultSplit;
        _masterVC = [[SMMasterViewController alloc] init];
    }
    return self;
}
    
#pragma mark -
#pragma mark - ViewController Lifecycle
    
- (void)loadView {
    
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    
    if (_splitType == SMTabbedSplt) {
        [self.view addSubview:_tabBar.view];
    }
    
    [self.view addSubview:_masterVC.view];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_masterVC.view.frame];
    _masterVC.view.layer.masksToBounds = NO;
    _masterVC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _masterVC.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _masterVC.view.layer.shadowOpacity = 1.5f;
    _masterVC.view.layer.shadowRadius = 2.5f;
    _masterVC.view.layer.shadowPath = shadowPath.CGPath;
    
    [self gotoLogin];
}
    
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (_masterIsHidden)
    return;
    //hideTab
    NSString *hideTab = [PersonInfoModel sharedManage].hideTab;
    if ([hideTab intValue] != 1) {
        CGRect masterFrame = [self masterVCFrame];
        _masterVC.view.frame = masterFrame;
    }
}
    
    
#pragma mark -
#pragma mark - Frames
    
- (CGRect)masterVCFrame {
    CGFloat width = self.view.bounds.size.width;
    return (_splitType == SMTabbedSplt) ? CGRectMake(TabbedSplit_Width, 0, width-TabbedSplit_Width, self.view.bounds.size.height) : CGRectMake(0, 0, 320, self.view.bounds.size.height);
}

- (CGRect)detailVCFrame {
    return (_splitType == SMTabbedSplt) ? CGRectMake(TabbedSplit_Width + 320 + 1, 0, self.view.bounds.size.width - 1, self.view.bounds.size.height) : CGRectMake(320 + 1, 0, self.view.bounds.size.width - 1, self.view.bounds.size.height);
}
    
#pragma mark -
#pragma mark - Properties
    
- (UIViewController *)masterViewController {
    
    return _masterVC.viewController;
}
    
- (void)setViewControllers:(NSArray *)viewControllers {
    
    _viewControllers = viewControllers;
    
    _masterVC.viewController = _viewControllers[0];
}
    
- (void)setBackground:(UIColor *)background {
    
    _tabBar.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dock_background.png"]];
    _masterVC.view.backgroundColor = background;
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(TabbedSplit_Width - 0.5, 0, 0.5, self.view.frame.size.height)];
    lineImageView.backgroundColor = [UIColor colorWithHex:@"#e5e5e5" alpha:1.0];
    [_tabBar.view addSubview:lineImageView];
}
    
- (void)setTabsViewControllers:(NSArray *)tabsViewControllers {
    
    _tabsViewControllers = tabsViewControllers;
    _tabBar.tabsButtons = _tabsViewControllers;
}
    
- (void)setActionsButtons:(NSArray *)actionsTabs {
    
    _actionsButtons = actionsTabs;
    _tabBar.actionsButtons = _actionsButtons;
}
    
#pragma mark -
#pragma mark - Actions
    
    
- (void)gotoLogin {
    //
    //    NSString *userCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"userCode"];
    //    if (!userCode || [userCode isEqualToString:@""]) {
    //        UIStoryboard *loginSB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    //        LoginViewController *loginVC = [loginSB instantiateViewControllerWithIdentifier:@"login"];
    //        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    //        [self presentViewController:nav animated:NO completion:nil];
    //    }
}
    
- (void)hideMaster {
    
    CATransition *transitionMaster = [CATransition animation];
    transitionMaster.type = kCATransitionPush;
    transitionMaster.subtype = kCATransitionFromRight;
    [_masterVC.view.layer addAnimation:transitionMaster forKey:@"hideOrAppear"];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        _masterIsHidden = YES;
        [self.view layoutIfNeeded];
    }];
}
    
- (void)showMaster {
    
    _masterIsHidden = NO;
    [self.view layoutIfNeeded];
    
    CATransition *transitionMaster = [CATransition animation];
    transitionMaster.type = kCATransitionPush;
    transitionMaster.subtype = kCATransitionFromLeft;
    transitionMaster.duration = 0.2;
    [_masterVC.view.layer addAnimation:transitionMaster forKey:@"hideOrAppear"];
}
    
#pragma mark -
#pragma mark - TabBarDelegate
    
- (void)tabBar:(SMTabBar *)tabBar selectedViewController:(UIViewController *)vc {
    
    if (_masterIsHidden) {
        _masterIsHidden = NO;
        [self.view setNeedsLayout];
    }
    
    _masterVC.viewController = vc;
}
    
@end

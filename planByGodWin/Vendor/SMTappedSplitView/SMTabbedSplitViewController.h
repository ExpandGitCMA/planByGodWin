//
//  SMSplitViewController.h
//  SMSplitViewController
//
//  Created by Sergey Marchukov on 15.02.14.
//  Copyright (c) 2014 Sergey Marchukov. All rights reserved.
//
//  This content is released under the ( http://opensource.org/licenses/MIT ) MIT License.
//  Repository: https://github.com/sergik-ru/SMTabbedSplitViewController
//  Version 1.0.3
//

#import <UIKit/UIKit.h>
#import "DFCHeader_pch.h"
#import "SMMasterViewController.h"
#import "SMTabBar.h"
#import "SMTabBarItemCell.h"
#import "SMTabBarItem.h"
typedef NS_ENUM(NSUInteger, SMSplitType) {
    
    SMTabbedSplt,
    SMDefaultSplit
};

//定义枚举类型
typedef NS_ENUM(NSInteger, SMSplitCategoryType){
    SMSplitHomeKey         = 0,
    SMSplitBoardKey        = 1,
    SMSplitResourcesKey    = 2,//资源库
    SMSplitReceiveKey      = 3,//收发中心
    SMSplitSyllabusInKey   = 4,
    SMSplitMyClassKey      = 5,
    SMSplitMyCenterKey     = 6,
};


@class SMTabBar;

@interface SMTabbedSplitViewController : UIViewController

@property (nonatomic, strong) SMTabBar *tabBar;
@property (nonatomic, weak) UIColor *background;
@property (nonatomic, strong) NSArray *tabsViewControllers;
@property (nonatomic, strong) NSArray *actionsButtons;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, readonly, weak) UIViewController *masterViewController;
@property (nonatomic, weak) UIViewController *detailViewController;
@property (nonatomic) SMSplitType splitType;
@property (nonatomic, strong) SMMasterViewController *masterVC;

- (id)initTabbedSplit;
- (id)initSplit;

- (void)hideMaster;
- (void)showMaster;

@end

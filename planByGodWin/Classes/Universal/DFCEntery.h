//
//  DFCEntery.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMTabbedSplitViewController.h"
#import "SMTabbedSplitVC.h"

#import "ElecBoardDetailViewController.h"

@interface DFCEntery : NSObject
+ (void)switchToHomeViewController:(UIViewController*)controller;
+ (void)switchToLoginViewController;
+ (void)switchToOnClassViewController:(ElecBoardDetailViewController*)controller;
+(void)switchNotFistViewController;
+(void)showToHomeViewController:(UIViewController*)controller;
@end

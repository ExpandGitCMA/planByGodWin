//
//  AppDelegate.h
//  DFCEducation
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElecBoardDetailViewController.h"

typedef void(^BackgroundURLSessionCompletionHandler)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) BackgroundURLSessionCompletionHandler backgroundURLSessionCompletionHandler;

+ (instancetype)sharedDelegate;

@property (nonatomic, strong) ElecBoardDetailViewController *onClassViewController;

- (void)stopCheckLogoutTimer;
-(void)openSocketTask;

@end


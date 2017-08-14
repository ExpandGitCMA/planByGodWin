//
//  DFCEntery.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCEntery.h"
#import "AppDelegate.h"
#import "DFCLoginViewController.h"
#import "DFCWelcomeViewController.h"
#import "SMTabbedSplitViewController.h"


@implementation DFCEntery
+(void)switchToLoginViewController{
    AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = nil;
    UIStoryboard *login = [UIStoryboard storyboardWithName:@"DFCLogin" bundle:nil];
     DFCLoginViewController *loginVC = [login instantiateViewControllerWithIdentifier:@"login"];
     [[self class] showToHomeViewController:loginVC];
}

+(void)switchNotFistViewController{
     AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
     appDelegate.window.rootViewController = nil;
     DFCWelcomeViewController  *welcome   =   [[DFCWelcomeViewController alloc] init];
    [[self class] showToHomeViewController:welcome];
}

+ (void)switchToOnClassViewController:(ElecBoardDetailViewController*)controller {
    AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = nil;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
    [[self class] showToHomeViewController:navi];
}

+ (void)switchToHomeViewController:(UIViewController*)controller{
    AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = nil;
    appDelegate.window.backgroundColor = [UIColor whiteColor];
     //[[self class] showToHomeViewController:controller];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
     [[self class] showUI:navi];
}

+(void)showToHomeViewController:(UIViewController*)controller{
    AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = controller;
    appDelegate.window.backgroundColor = [UIColor whiteColor];
    if (![appDelegate.window isKeyWindow]) {
        [appDelegate.window makeKeyAndVisible];
    }
}

+ (void)showUI:(UINavigationController *)navi {
    AppDelegate *appDelegate =  (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = navi;
    if (![appDelegate.window isKeyWindow]) {
        [appDelegate.window makeKeyAndVisible];
    }
}

@end

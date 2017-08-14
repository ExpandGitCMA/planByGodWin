//
//  DFCProgressHUD.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/14.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCProgressHUD.h"


@implementation DFCProgressHUD

+ (MBProgressHUD *)showLoadText:(NSString *)text
              atView:(UIView *)view
            animated:(BOOL)animated{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:animated];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.maskView.hidden = NO;
    hud.label.text = text;
    hud.label.textColor = [UIColor whiteColor];
    return hud;
}

+ (void)showText:(NSString *)text
          atView:(UIView *)view
        animated:(BOOL)animated
  hideAfterDelay:(CGFloat)delay {
    
    if ([NSThread isMainThread]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:animated];
        
        hud.mode = MBProgressHUDModeText;
        hud.maskView.hidden = YES;
        hud.label.text = text;
        hud.label.textColor = [UIColor whiteColor];
        
        [hud hideAnimated:YES afterDelay:delay];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:animated];
            hud.mode = MBProgressHUDModeText;
            hud.maskView.hidden = YES;
            hud.label.text = text;
            hud.label.textColor = [UIColor whiteColor];
            [hud hideAnimated:YES afterDelay:delay];
        });
    }
}



+ (void)showErrorWithStatus:(NSString *)string
                   duration:(NSTimeInterval)duration {
    UIWindow *window = [UIApplication sharedApplication].keyWindow; 
    
    [DFCProgressHUD showText:string
                      atView:window
                    animated:NO
              hideAfterDelay:duration];
}

+ (void)showErrorWithStatus:(NSString *)string {
    [DFCProgressHUD showErrorWithStatus:string
                               duration:.8f];
}

+ (void)showSuccessWithStatus:(NSString *)string {
    [DFCProgressHUD showSuccessWithStatus:string duration:.8f];
}

+ (void)showSuccessWithStatus:(NSString *)string
                     duration:(NSTimeInterval)duration {
    [DFCProgressHUD showText:string
                      atView:[UIApplication sharedApplication].keyWindow
                    animated:NO
              hideAfterDelay:duration];
}

@end

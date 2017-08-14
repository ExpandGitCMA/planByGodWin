//
//  DFCProgressHUD.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/14.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface DFCProgressHUD : NSObject
// add 提示加载中
+ (MBProgressHUD *)showLoadText:(NSString *)text
          atView:(UIView *)view
        animated:(BOOL)animated;




+ (void)showText:(NSString *)text
          atView:(UIView *)view
        animated:(BOOL)animated
  hideAfterDelay:(CGFloat)delay;

+ (void)showErrorWithStatus:(NSString *)string
                   duration:(NSTimeInterval)duration;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showSuccessWithStatus:(NSString *)string;
+ (void)showSuccessWithStatus:(NSString *)string
                     duration:(NSTimeInterval)duration;

@end

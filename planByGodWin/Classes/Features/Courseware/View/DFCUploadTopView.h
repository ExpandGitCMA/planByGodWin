//
//  DFCUploadTopView.h
//  planByGodWin
//
//  Created by zeros on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFCUploadTopView : UIView

- (instancetype)initWithConfirmHandler:(void (^)())handler cancelHandler:(void (^)())cancelHandler isNeedSend:(BOOL)isNeedSend;

@end

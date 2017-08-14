//
//  DFCEditTopView.h
//  planByGodWin
//
//  Created by zeros on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFCEditTopView : UIView

@property (nonatomic, copy) void (^firstHandler)();
@property (nonatomic, copy) void (^secondHandler)();
@property (nonatomic, copy) void (^thirdHandler)();
@property (nonatomic, copy) void (^tapHandler)();

@property (nonatomic, strong) UIButton *sharedButton;

- (instancetype)initWithConfirmHandler:(void (^)())handler;

@end

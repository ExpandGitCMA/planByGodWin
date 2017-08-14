//
//  DFCHomeFunctionView.h
//  planByGodWin
//
//  Created by zeros on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFCHomeFunctionView : UIView

@property (nonatomic, copy) void(^tapFun)();

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;

@end

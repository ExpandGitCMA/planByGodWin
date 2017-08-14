//
//  DFCUploadTopView.m
//  planByGodWin
//
//  Created by zeros on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUploadTopView.h"

@interface DFCUploadTopView ()

@property (nonatomic, copy) void(^confirmFn)();
@property (nonatomic, copy) void(^cancelFn)();

@end

@implementation DFCUploadTopView

- (instancetype)initWithConfirmHandler:(void (^)())handler cancelHandler:(void (^)())cancelHandler isNeedSend:(BOOL)isNeedSend
{
    
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)]) {
        self.confirmFn = handler;
        self.cancelFn = cancelHandler;
        self.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
        UITextField *title = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        title.text = @"选择要上传的课件";
        if (isNeedSend) {
                title.text = @"选择要发送的课件";
        }
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:20];
        [self addSubview:title];
        [title makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(10);
            make.width.equalTo(200);
            make.height.equalTo(60);
        }];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        [cancelButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(title);
            make.left.equalTo(self).offset(10);
            make.width.equalTo(80);
            make.height.equalTo(44);
        }];
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (isNeedSend) {
            [confirmButton setTitle:@"下一步" forState:UIControlStateNormal];
        } else {
            [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        }
        [confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmButton];
        [confirmButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(title);
            make.right.equalTo(self).offset(-10);
            make.width.equalTo(80);
            make.height.equalTo(44);
        }];
        
    }
    return self;
}

- (void)cancelAction:(UIButton *)sender
{
    self.cancelFn();
    [self removeFromSuperview];
}

- (void)confirmAction:(UIButton *)sender
{
    self.confirmFn();
    [self cancelAction:nil];
}

@end

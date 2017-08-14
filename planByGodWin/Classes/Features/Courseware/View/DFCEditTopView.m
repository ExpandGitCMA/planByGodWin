//
//  DFCEditTopView.m
//  planByGodWin
//
//  Created by zeros on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCEditTopView.h"
static CGFloat kWidth = 32;
@interface DFCEditTopView ()

@property (nonatomic, copy) void(^confirmFn)();

@end

@implementation DFCEditTopView

- (instancetype)initWithConfirmHandler:(void (^)())handler
{
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)]) {
        self.confirmFn = handler;
        
        self.backgroundColor = kUIColorFromRGB(BackgroundColor);
        UITextField *title = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        title.text = @"我的课件";
        title.textColor = [UIColor blackColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:title];
        [title makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(10);
            make.width.equalTo(200);
            make.height.equalTo(60);
        }];
        
        
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmButton];
        [confirmButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(title);
            make.right.equalTo(self).offset(-10);
            make.width.equalTo(80);
            make.height.equalTo(44);
        }];
        
        UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [firstButton setImage:[UIImage imageNamed:@"coursewareList_copy"] forState:UIControlStateNormal];
//        [firstButton setTitle:@"复制" forState:UIControlStateNormal];
        firstButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [firstButton addTarget:self action:@selector(firstAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:firstButton];
        [firstButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(title);
            make.left.equalTo(self).offset(10);
            make.width.equalTo(kWidth);
            make.height.equalTo(kWidth);
        }];
        
        UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [secondButton setImage:[UIImage imageNamed:@"coursewareList_delete"] forState:UIControlStateNormal];
//        [secondButton setTitle:@"删除" forState:UIControlStateNormal];
        [secondButton addTarget:self action:@selector(secondAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:secondButton];
        [secondButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(title);
            make.left.equalTo(firstButton.right).offset(6);
            make.width.equalTo(kWidth);
            make.height.equalTo(kWidth);
        }];
        
        UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [thirdButton setImage:[UIImage imageNamed:@"Courseware_Airdrop"] forState:UIControlStateNormal];
        thirdButton.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        //        [secondButton setTitle:@"删除" forState:UIControlStateNormal];
        [thirdButton addTarget:self action:@selector(thirdAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:thirdButton];
        [thirdButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(title);
            make.left.equalTo(secondButton.right).offset(6);
            make.width.equalTo(kWidth);
            make.height.equalTo(kWidth);
        }];
        _sharedButton = thirdButton;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapAction {
    self.tapHandler();
}

- (void)dealloc
{
    DEBUG_NSLog(@"editTopView dealloc");
}

- (void)confirmAction:(UIButton *)sender
{
    self.confirmFn();
    [self removeFromSuperview];
}

- (void)firstAction:(UIButton *)sender
{
    self.firstHandler();
}

- (void)thirdAction:(UIButton *)sender
{
    self.thirdHandler();
}

- (void)secondAction:(UIButton *)sender
{
    self.secondHandler();
}



@end

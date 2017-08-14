//
//  KDBlockAlertView.m
//  Koudaitong
//
//  Created by ShaoTianchi on 14-8-4.
//  Copyright (c) 2014年 qima. All rights reserved.
//

#import "KDBlockAlertView.h"

@interface KDBlockAlertView ()<UIAlertViewDelegate>
@property (nonatomic,copy) ClickedBlock clickBlock;
@end


@implementation KDBlockAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message block:(ClickedBlock)block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        self.clickBlock = [block copy];
    }
    return self;
}

- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message block:(ClickedBlock)block cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *) confirmButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:confirmButtonTitle,otherButtonTitle,nil];
    if (self) {
        self.clickBlock = [block copy];
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (_clickBlock) {
        _clickBlock(buttonIndex);
    }
}

- (void)show{
    [super show];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

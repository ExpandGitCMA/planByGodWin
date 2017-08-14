//
//  KDBlockActionSheet.m
//  Koudaitong
//
//  Created by ShaoTianchi on 14/10/30.
//  Copyright (c) 2014年 qima. All rights reserved.
//

#import "KDBlockActionSheet.h"

@interface KDBlockActionSheet ()<UIActionSheetDelegate>
@property (nonatomic,copy) ClickedBlock clickBlock;
@end

@implementation KDBlockActionSheet

- (instancetype)initWithTitle:(NSString *)title clickBlock:(ClickedBlock)block cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        self.clickBlock = [block copy];
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (_clickBlock) {
        _clickBlock(buttonIndex);
    } 
}

@end

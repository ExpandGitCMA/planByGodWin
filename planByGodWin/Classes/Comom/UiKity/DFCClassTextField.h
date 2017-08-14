//
//  DFCClassTextField.h
//  planByGodWin
//
//  Created by 陈美安 on 16/11/18.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCClassTextField;

@protocol ClassTextFieldDelegate <NSObject>
@optional
- (void)classCode:(DFCClassTextField *)classCode sender:(UIButton*)sender;
@end

@interface DFCClassTextField : UITextField
@property (nonatomic,weak) id<ClassTextFieldDelegate>classdelegate;
-(instancetype)initWithFrame:(CGRect)frame imgIcon:(NSString*)imgIcon holder:(NSString*)holder;
@end

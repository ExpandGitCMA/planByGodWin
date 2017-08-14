//
//  DFCTPassWordField.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCTPassWordField;

@protocol PassWordFieldDelegate <NSObject>
@optional
- (void)redactPassWord:(DFCTPassWordField *)redactPassWord code:(UIButton*)code;
- (void)deleteBackward;
@end

@interface DFCTPassWordField : UITextField
@property (nonatomic,weak) id<PassWordFieldDelegate>passWorddelegate;
-(instancetype)initWithFrame:(CGRect)frame imgIcon:(NSString*)imgIcon holder:(NSString*)holder;
-(void)textFieldBeginEditing;//开始编辑
-(void)textFieldDidEndEditing;//结束编辑
@end

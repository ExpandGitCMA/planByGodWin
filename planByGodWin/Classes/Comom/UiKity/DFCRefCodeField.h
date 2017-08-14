//
//  DFCRefCodeField.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCRefCodeField;

@protocol RefCodeFieldDelegate <NSObject>
@optional
- (void)sendCode:(DFCRefCodeField *)sendCode code:(UIButton*)code;
@end


@interface DFCRefCodeField : UITextField
@property (nonatomic,weak) id<RefCodeFieldDelegate>refCodedelegate;
-(instancetype)initWithFrame:(CGRect)frame imgIcon:(NSString*)imgIcon holder:(NSString*)holder;
@property (nonatomic,strong) UIButton *passCodeFn;
@end

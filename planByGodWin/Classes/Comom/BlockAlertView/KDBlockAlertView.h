//
//  KDBlockAlertView.h
//  Koudaitong
//
//  Created by ShaoTianchi on 14-8-4.
//  Copyright (c) 2014年 qima. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ClickedBlock) (NSInteger buttonIndex);
@interface KDBlockAlertView : UIAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message block:(ClickedBlock)block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message block:(ClickedBlock)block cancelButtonTitle:(NSString *)cancelButtonTitle confirmButtonTitle:(NSString *) confirmButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;

@end

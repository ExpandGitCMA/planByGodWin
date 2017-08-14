//
//  NSString+NSStringSizeString.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/2.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (NSStringSizeString)
- (CGFloat)sizeWithForRowWidth:(CGFloat)fontSize;
-(CGFloat)sizeWithForRowHeight:(CGFloat)fontSize;
- (BOOL)isEmptyString;
@end

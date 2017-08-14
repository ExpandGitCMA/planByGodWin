//
//  NSString+NSStringSizeString.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/2.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "NSString+NSStringSizeString.h"

@implementation NSString (NSStringSizeString)
-(CGFloat)sizeWithForRowWidth:(CGFloat)fontSize{
    CGSize titleSize=[self sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    return titleSize.width;
}

-(CGFloat)sizeWithForRowHeight:(CGFloat)fontSize{
    CGSize titleSize=[self sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    return titleSize.height;
}

//判断字符串是否为空
- (BOOL)isEmptyString{
    
    if (self == nil || self == NULL) {
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    
     return NO;
}
@end

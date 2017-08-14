//
//  UIImage+DFCImageCache.m
//  planByGodWin
//
//  Created by DFC on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "UIImage+DFCImageCache.h"

@implementation UIImage (DFCImageCache)
///缩放图片
+ (instancetype)resizeImage:(NSString *)imgName {
    UIImage *backImage = [UIImage imageNamed:imgName];
    backImage =  [backImage stretchableImageWithLeftCapWidth:backImage.size.width / 2 topCapHeight:backImage.size.height / 2];
    return backImage;
}
@end

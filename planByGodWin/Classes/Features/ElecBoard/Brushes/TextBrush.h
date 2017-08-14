//
//  TextBrush.h
//  PBDStudent
//
//  Created by DaFenQi on 16/8/24.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TextBrush : NSObject

- (void)drawText:(NSString *)text
          inRect:(CGRect)rect
       superRect:(CGRect)superRect
         context:(CGContextRef)context
            font:(UIFont *)font
           color:(UIColor *)color;

@end

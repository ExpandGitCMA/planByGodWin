//
//  WritingBrush.h
//  planByGodStudent
//
//  Created by hmy2015 on 16/5/22.
//  Copyright © 2016年 szcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseBrush.h"

@interface WritingBrush : BaseBrush

typedef void(^DFQPostBackImageFn)(UIImage *image);

@property (nonatomic, copy) DFQPostBackImageFn postBackImage;

@end

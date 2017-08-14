//
//  DFCGodWinImageView.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/27.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCSendObjectModel.h"
typedef void(^SucceedBlock)();

@interface DFCGodWinImageView : UIView
+(DFCGodWinImageView*)initWithDFCGodWinImageViewFrame:(CGRect)frame;
@property (nonatomic, strong) DFCSendObjectModel *model;
@property (nonatomic,copy) SucceedBlock succeed;
@end

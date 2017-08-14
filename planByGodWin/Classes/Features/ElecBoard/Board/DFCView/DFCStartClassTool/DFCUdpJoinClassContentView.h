//
//  DFCUdpJoinClassContentView.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^kClassCodeBlock)(NSString *classCode);

@interface DFCUdpJoinClassContentView : UIView

+ (instancetype)joinClassContentViewWithFrame:(CGRect)frame;
@property (nonatomic, copy) kClassCodeBlock classCodeBlock;

@end

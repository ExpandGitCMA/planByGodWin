//
//  DFCUdpStartClassContentView.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^kConfigChangedBlock)(NSString *text, BOOL allowLeave);

@interface DFCUdpStartClassContentView : UIView

+ (instancetype)startClassContentViewWithFrame:(CGRect)frame;

@property (nonatomic, copy) kConfigChangedBlock configBlock;
@property (nonatomic, copy) NSString *classTitle;

@end

//
//  DFCMsgView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCMessageFrameModel.h"

@interface DFCMsgView : UIView
//正文背景泡泡
@property (nonatomic, strong) UIButton *msgButton;
//数据
@property (nonatomic, strong) DFCMessageFrameModel *msgModel;
@end

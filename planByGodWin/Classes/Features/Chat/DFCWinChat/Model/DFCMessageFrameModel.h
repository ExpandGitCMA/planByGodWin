//
//  DFCMessageFrameModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFCChatModel.h"


@interface DFCMessageFrameModel : NSObject
@property (nonatomic, strong)  DFCChatModel*model;
@property (nonatomic, assign) CGRect timeFrame;
@property (nonatomic, assign) CGRect messageBtnFrame;
@property (nonatomic, assign) CGRect iconFrame;
@property (nonatomic, assign) CGFloat rowHeight;
@end

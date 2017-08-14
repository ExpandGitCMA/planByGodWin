//
//  DFCOpenBoardCommand.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

// 主线程中使用

#import "DFCCommand.h"

@class DFCCoursewareModel;
@class ElecBoardDetailViewController;

typedef void(^kOpenBoardFinishedBlock)();

@interface DFCOpenBoardCommand : DFCCommand

- (instancetype)initWithCoureseware:(DFCCoursewareModel *)info
                       openAtController:(ElecBoardDetailViewController *)controller
                         finshBlock:(kOpenBoardFinishedBlock)finshBlock;

@end

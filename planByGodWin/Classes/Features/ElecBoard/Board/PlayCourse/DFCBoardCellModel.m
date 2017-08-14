//
//  DFCBoardModel.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCBoardCellModel.h"

@implementation DFCBoardCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _title = @"课件";
        _taskOrder = @"任务0/5";
        _isSelected = NO;
        _canEdit = NO;
    }
    return self;
}

@end

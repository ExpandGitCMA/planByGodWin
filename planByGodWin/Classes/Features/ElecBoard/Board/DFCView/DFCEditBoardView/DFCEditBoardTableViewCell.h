//
//  DFCEditBoardTableViewCell.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCEditItemModel.h"

typedef NS_ENUM(NSUInteger, kCellType) {
    kCellTypeEdit,  // 编辑
    
    kCellTypeLock,  // 加锁
    
    kCellTypeAddSource,
};

@interface DFCEditBoardTableViewCell : UITableViewCell

@property (nonatomic, strong) DFCEditItemModel *itemModel;
@property (nonatomic, assign) kCellType cellType;

@end

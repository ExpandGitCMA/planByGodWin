//
//  DFCFileCell.h
//  planByGodWin
//
//  Created by dfc on 2017/6/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCContactFileModel.h"

@class DFCFileCell;

typedef NS_ENUM(NSInteger,DFCCellType) {
    DFCCellNormal,  // 正常
    DFCCellEdit //   编辑状态
};

@protocol DFCFileCellDelegate <NSObject>
- (void)fileCell:(DFCFileCell *)cell disconnectFile:(UIButton *)sender;
@end

@interface DFCFileCell : UICollectionViewCell

@property (nonatomic,assign) DFCCellType cellType;
@property (nonatomic,strong) DFCContactFileModel *contactFileModel;
@property (nonatomic,weak) id<DFCFileCellDelegate >delegate;

@end

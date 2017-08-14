//
//  DFCCoursewareInfoYHCell.h
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DFCCoursewareModel.h"
#import "DFCGoodsModel.h"

@class DFCCoursewareInfoYHCell;
@protocol DFCCoursewareInfoYHCellDelegate <NSObject>
// 选取缩略图
- (void)coursewareInfoCell:(DFCCoursewareInfoYHCell *)cell didChangeSelectedCoverImgs:(NSArray *)selectedImgs;

@end

@interface DFCCoursewareInfoYHCell : UITableViewCell

@property (nonatomic,weak) id<DFCCoursewareInfoYHCellDelegate>delegate;
@property (nonatomic,strong) DFCGoodsModel *goodsModel;

@property (nonatomic,strong) NSMutableArray *selectedCoverImages;

@end

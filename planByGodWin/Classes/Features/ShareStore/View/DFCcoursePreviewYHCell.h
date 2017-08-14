//
//  DFCcoursePreviewYHCell.h
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"



@class DFCcoursePreviewYHCell;
@protocol DFCcoursePreviewYHCellDelegate <NSObject>
- (void)previewCell:(DFCcoursePreviewYHCell *)cell previewGoodsModel:(DFCGoodsModel *)goodsModel currentIndex:(NSInteger)index;
@end

@interface DFCcoursePreviewYHCell : UITableViewCell

@property (nonatomic,weak) id<DFCcoursePreviewYHCellDelegate>delegate;
@property (nonatomic,strong) DFCGoodsModel *goodsModel;

@property (nonatomic,assign) BOOL isFromMyStore;

@end

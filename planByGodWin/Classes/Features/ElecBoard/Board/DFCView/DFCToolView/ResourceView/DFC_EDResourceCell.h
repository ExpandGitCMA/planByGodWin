//
//  DFC_EDResourceCell.h
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFC_EDResourceItem.h"
@class DFC_EDResourceCell;
@protocol EDResourceCellDelegate <NSObject>
@required
// 编辑可删除
- (void)editItemInResourceCell:(DFC_EDResourceCell *)cell;
// 删除
- (void)deleteItemInResourceCell:(DFC_EDResourceCell *)cell;
@end

@interface DFC_EDResourceCell : UICollectionViewCell
@property (nonatomic,strong) DFC_EDResourceItem *resourceItem;

@property (nonatomic,weak) id<EDResourceCellDelegate>delegate;
@end

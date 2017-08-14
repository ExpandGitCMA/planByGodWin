//
//  DFCPreviewCommentYHCell.h
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
@protocol  DFCPreviewCommentYHCellDelegate <NSObject>
/**
 写评论
 */
- (void)commentCurrentCourse;
@end

@interface DFCPreviewCommentYHCell : UITableViewCell
@property (nonatomic,weak) id<DFCPreviewCommentYHCellDelegate>delegate;
@property (nonatomic,strong) DFCGoodsModel *goodsModel;


/**
 预览我的商店中课件时，不可以写评论
 */
- (void)previewCoursewareFromMystore;
@end

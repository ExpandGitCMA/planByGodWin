//
//  DFCAboutVideoCell.h
//  planByGodWin
//
//  Created by dfc on 2017/6/20.
//  Copyright © 2017年 DFC. All rights reserved.
//  课件相关上课视频

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
#import "DFCVideoCell.h"

@protocol  DFCAboutVideoCellDelegate <NSObject>
- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel clickToPreviewVideoWithVideoModel:(DFCVideoModel *)videoModel;
@end

@interface DFCAboutVideoCell : UITableViewCell

@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,weak) id<DFCAboutVideoCellDelegate> delegate;

@end

//
//  DFCCoursewareYHCell.h
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCCoverImageModel.h"
#import "DFCGoodsModel.h"
@interface DFCCoursewareYHCell : UICollectionViewCell
@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,copy) DFCCoverImageModel *coverImageModel;

@end

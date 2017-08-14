//
//  DFCCommentYHController.h
//  planByGodWin
//
//  Created by dfc on 2017/5/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"

typedef void(^DFCFinishComment)(NSInteger score);   // 新评分
@interface DFCCommentYHController : UIViewController
@property (nonatomic,strong) DFCGoodsModel *goodsModel;
@property (nonatomic,copy) DFCFinishComment finishComment;
@end

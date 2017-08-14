//
//  DFCShareYHController.h
//  planByGodWin
//
//  Created by dfc on 2017/4/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
#import "DFCYHSubjectModel.h"

@interface DFCShareYHController : UIViewController
@property (nonatomic,strong) DFCGoodsModel *externGoodsModel; // 查看更多同类作品
@property (nonatomic,strong) DFCYHSubjectModel *externSubjectModel;   // 查看更多科目
@end

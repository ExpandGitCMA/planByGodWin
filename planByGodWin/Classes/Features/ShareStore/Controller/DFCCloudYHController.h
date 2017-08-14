//
//  DFCCloudYHController.h
//  planByGodWin
//
//  Created by dfc on 2017/4/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
#import "DFCYHSubjectModel.h"

typedef void(^DFCEditBlock)(); 

@interface DFCCloudYHController : UIViewController
@property (nonatomic,assign) BOOL isFromProcess;
@property (nonatomic,copy) DFCEditBlock editBlock;

@property (nonatomic,strong) DFCGoodsModel *goodsModel; // 查看作者相关作品
@property (nonatomic,strong) DFCYHSubjectModel *externSubjectModel;   // 查看更多科目
@end

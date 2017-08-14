//
//  DFCGoodstoreCell.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodsModel.h"
@interface DFCGoodstoreCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *tagImg;
@property(nonatomic,strong)DFCGoodsModel*model;
@end

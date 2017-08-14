//
//  HandoverScreenCell.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//HandoverSelectedModel

#import <UIKit/UIKit.h>
#import "HandoverSelectedModel.h"
@interface HandoverScreenCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *handle;
@property (nonatomic, strong) HandoverSelectedModel *model;
-(void)setSelectCell:(BOOL)isSelect;
@end

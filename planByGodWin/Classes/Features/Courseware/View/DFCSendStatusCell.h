//
//  DFCSendStatusCell.h
//  planByGodWin
//
//  Created by 陈美安 on 17/2/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCUploadRecordModel.h"
#import "DFCSendRecordModel.h"
@interface DFCSendStatusCell : UITableViewCell
@property (nonatomic, strong) DFCUploadRecordModel *model;
@property (nonatomic, strong) DFCSendRecordModel *send;
@end

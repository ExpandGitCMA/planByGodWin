//
//  SendMessgeCell.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCMessageFrameModel.h"
@interface SendMessgeCell : UITableViewCell
@property (nonatomic, strong)  DFCChatModel*model;
@property (nonatomic, strong) DFCMessageFrameModel *frameMOdel;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

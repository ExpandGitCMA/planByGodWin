//
//  DFCSendHeaderView.h
//  planByGodWin
//
//  Created by zeros on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCSendGroupModel;

@interface DFCSendHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) DFCSendGroupModel *group;

+ (instancetype)headerView:(UITableView *)tableView selectFn:(void (^) ())selectFn;

@end

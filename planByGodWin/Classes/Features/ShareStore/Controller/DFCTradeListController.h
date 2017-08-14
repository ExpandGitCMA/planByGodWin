//
//  DFCTradeListController.h
//  planByGodWin
//
//  Created by dfc on 2017/5/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DFCChooseBlock)(NSInteger index);
@interface DFCTradeListController : UITableViewController
@property (nonatomic,copy) DFCChooseBlock chooseBlock;
@end

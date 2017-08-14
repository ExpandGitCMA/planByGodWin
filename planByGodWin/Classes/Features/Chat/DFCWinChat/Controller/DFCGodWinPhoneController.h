//
//  DFCBoxesPhoneController.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/26.
//  Copyright © 2017年 DFC. All rights reserved.
//DFCGodWinPhoneController

#import <UIKit/UIKit.h>
#import "DFCGodWinPhoneAdapter.h"
@interface DFCGodWinPhoneController : UIViewController
@property (nonatomic,strong)DFCGodWinPhoneAdapter* adapter;
-(void)reloadDataSource;
@end

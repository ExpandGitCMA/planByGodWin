//
//  DFCCreateFileViewController.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFCCreateFileDelegate <NSObject>
- (void)didCreateFileType:(NSInteger)type;
@end
@interface DFCCreateFileViewController : UITableViewController
-(instancetype)initWithDelegate:(id<DFCCreateFileDelegate>)delgate;
@end

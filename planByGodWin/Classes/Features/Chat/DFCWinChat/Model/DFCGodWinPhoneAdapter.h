//
//  DFCPhoneAdapter.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/26.
//  Copyright © 2017年 DFC. All rights reserved.
// 

#import <UIKit/UIKit.h>
#import "DFCSendObjectModel.h"
@class DFCGodWinPhoneAdapter;
@protocol GodWinPhoneDelegate <NSObject>
@required
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexModel:(DFCSendObjectModel*)model;
-(void)didSelectRowAtIndexClass:(DFCGodWinPhoneAdapter*)didSelectRowAtIndexClass;
@end


@interface DFCGodWinPhoneAdapter: NSObject<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, assign) id<GodWinPhoneDelegate> delegate;
- (instancetype)initWithtableView:(UITableView*)tableView;
@property(nonatomic,copy)NSArray*arraySource;
@end

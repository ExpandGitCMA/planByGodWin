//
//  DFCMineClass.h
//  planByGodWin
//  我的班级
//  Created by 陈美安 on 16/12/29.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCClassInfolist.h"

@class DFCMineClass;
@protocol MineClassDelegate <NSObject>
- (void)selectClassInfo:(DFCMineClass*)selectClassInfo  model:(DFCClassInfolist*)model;
@end

@interface DFCMineClass : UIView
@property(nonatomic,weak)id <MineClassDelegate>delegate;
-(DFCClassInfolist*)defaultClassInfo;

- (void)selectFirstClass;

@end

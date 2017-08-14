//
//  DFCMineSeminary.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCClassInfolist.h"

@class DFCMineSeminary;
@protocol DFCMineSeminaryDelegate <NSObject>
- (void)selectClassInfo:(DFCMineSeminary*)selectClassInfo  model:(DFCClassInfolist*)model;
@end

@interface DFCMineSeminary : UIView
@property(nonatomic,weak)id <DFCMineSeminaryDelegate>delegate;

-(DFCClassInfolist*)defaultClassInfo;

- (void)selectFirstClass;
- (BOOL)isScrolling;

@end

//
//  DFCClassSeminary.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCClassInfolist.h"

@class DFCClassSeminary;
@protocol DFCClassSeminaryDelegate <NSObject>

@optional

/*
 *@获取选择年级数据
 */
- (void)selectClassInfo:(DFCClassSeminary*)selectClassInfo  gradeInfo:(DFCGradeInfolist*)gradeInfo  classInfo:(DFCClassInfolist*)classInfo;
/*
 *@获取选择班级数据
 */
- (void)classInfo:(DFCClassSeminary*)classInfo   model:(DFCClassInfolist*)model;
@end

@interface DFCClassSeminary : UIView
@property(nonatomic,weak)id<DFCClassSeminaryDelegate>delegate;

- (void)selectFirstClass;
- (BOOL)isScrolling;

@end


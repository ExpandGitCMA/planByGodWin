//
//  DFCSeminary.h
//  planByGodWin
//  全校班级
//  Created by 陈美安 on 16/12/29.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCClassInfolist.h"

@class DFCSeminary;
@protocol SeminaryDelegate <NSObject>

@optional

/*
 *@获取选择年级数据
 */
- (void)selectClassInfo:(DFCSeminary*)selectClassInfo  gradeInfo:(DFCGradeInfolist*)gradeInfo  classInfo:(DFCClassInfolist*)classInfo;
/*
 *@获取选择班级数据
 */
- (void)classInfo:(DFCSeminary*)classInfo   model:(DFCClassInfolist*)model;
@end

@interface DFCSeminary : UIView
@property(nonatomic,weak)id<SeminaryDelegate>delegate;

- (void)selectFirstClass;

@end

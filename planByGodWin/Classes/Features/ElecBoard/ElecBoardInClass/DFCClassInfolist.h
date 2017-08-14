//
//  DFCClassInfolist.h
//  planByGodWin
//  学校班级和年级模型
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCClassInfolist : NSObject
@property(nonatomic,copy)NSString *classCode;
@property(nonatomic,copy)NSString *className;
@property(nonatomic,copy)NSString *classNick;
@property (nonatomic, copy) NSString *gradeCode;
@property(nonatomic,copy)NSString *roleType;
+(NSMutableArray*)jsonWithObj;
+ (DFCClassInfolist *)jsonWithDic:(NSDictionary *)dic;

@end

@interface DFCGradeInfolist : NSObject

@property (nonatomic, copy) NSString *gradeNick;
@property (nonatomic, copy) NSString *gradeCode;
@property (nonatomic, copy) NSString *gradeName;
+(NSMutableArray*)jsonWithGradeInfoObj;
+ (DFCGradeInfolist *)jsonWithDic:(NSDictionary *)dic;

@end

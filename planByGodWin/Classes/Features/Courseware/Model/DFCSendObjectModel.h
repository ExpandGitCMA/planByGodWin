//
//  DFCSendObjectModel.h
//  planByGodWin
//
//  Created by zeros on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ModelType) {
    ModelTypeStudent,   // 学生
    ModelTypeTeacher,   // 教师
    ModelTypeClass,    //  班级
};

@interface DFCSendObjectModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *imageUrl;

//教师
@property(nonatomic,copy)NSString*address;
@property(nonatomic,copy)NSString*imgUrl;
@property(nonatomic,copy)NSString*mobile;
@property(nonatomic,copy)NSString*schoolCode;
@property(nonatomic,copy)NSString*teacherCode;
@property(nonatomic,copy)NSString*qq;
@property(nonatomic,copy)NSString*userType;
@property(nonatomic,copy)NSString*wechatNo;
@property(nonatomic,copy)NSString*sex;

//学生
@property(nonatomic,copy)NSString*birthday;
@property(nonatomic,copy)NSString*certNo;
@property(nonatomic,copy)NSString*classJob;
@property(nonatomic,copy)NSString*parentName;
@property(nonatomic,copy)NSString*studentCode;
@property (nonatomic, copy) NSString *seatNo;//录播座位编码

@property (nonatomic,assign) ModelType modelType;

+ (NSArray<DFCSendObjectModel *> *)modelListForClassList:(NSArray *)classes;
+ (NSArray<DFCSendObjectModel *> *)modelListForPersonList:(NSArray *)persons;
+ (NSArray<DFCSendObjectModel *> *)modelListForTeacherList:(NSArray *)teachers;



@end

@interface DFCSendGroupModel : NSObject

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray<DFCSendObjectModel *> *objectList;
+ (NSMutableArray<DFCSendGroupModel *> *)modelListForClassInfo:(NSArray *)classsesInfo;
+ (instancetype)modelForTeacherList:(NSArray *)teachers;

@end

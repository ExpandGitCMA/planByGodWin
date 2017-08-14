//
//  DFCSendObjectModel.m
//  planByGodWin
//
//  Created by zeros on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendObjectModel.h"

@implementation DFCSendObjectModel

+ (NSArray<DFCSendObjectModel *> *)modelListForClassList:(NSArray *)classes
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in classes) {
        DFCSendObjectModel *model = [[DFCSendObjectModel alloc] init];
        model.name = [dic objectForKey:@"className"];
        model.code = [dic objectForKey:@"classCode"];
        model.modelType = ModelTypeClass;
        [list addObject:model];
    }
    return [list copy];
}

+ (NSArray<DFCSendObjectModel *> *)modelListForPersonList:(NSArray *)persons
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in persons) {
        DFCSendObjectModel *model = [[DFCSendObjectModel alloc] init];
        model.name = [dic objectForKey:@"name"];
        model.code = [dic objectForKey:@"studentCode"];
        model.imageUrl = [dic objectForKey:@"imgUrl"];
        model.modelType = ModelTypeStudent;
        
        model.address  = [dic objectForKey:@"address"];
        model.imgUrl = [dic objectForKey:@"imgUrl"];
        model.certNo   = [dic objectForKey:@"studentCode"];
        model.classJob  = [dic objectForKey:@"classJob"];
        model.name = [dic objectForKey:@"name"];
        model.qq  = [dic objectForKey:@"qq"];
        model.seatNo = [dic objectForKey:@"seatNo"];
        if ([[dic objectForKey:@"sex"] isEqualToString:@"M"]) {
            model.sex = @"男";
        } else {
            model.sex = @"女";
        }
        ;model.studentCode = [dic objectForKey:@"studentCode"];
        model.birthday  = [dic objectForKey:@"birthday"];
        model.mobile = [dic objectForKey:@"tel"];
        model.parentName = [dic objectForKey:@"parentName"];
        
        [list addObject:model];
    }
    return [list copy];
}

+ (NSArray<DFCSendObjectModel *> *)modelListForTeacherList:(NSArray *)teachers
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in teachers) {
        DFCSendObjectModel *model = [[DFCSendObjectModel alloc] init];
        model.name = [dic objectForKey:@"name"];
        model.code = [dic objectForKey:@"teacherCode"];
        model.imageUrl = [dic objectForKey:@"imgUrl"];
        model.modelType = ModelTypeTeacher;
        model.address  = [dic objectForKey:@"address"];
        model.imgUrl = [dic objectForKey:@"imgUrl"];
        model.mobile   = [dic objectForKey:@"mobile"];
        model.name = [dic objectForKey:@"name"];
        model.qq  = [dic objectForKey:@"qq"];
        model.schoolCode  = [dic objectForKey:@"schoolCode"];
        if ([[dic objectForKey:@"sex"] isEqualToString:@"M"]) {
            model.sex = @"男";
        } else {
            model.sex = @"女";
        }
        model.teacherCode = [dic objectForKey:@"teacherCode"];
        model.userType  = [dic objectForKey:@"userType"];
        model.wechatNo = [dic objectForKey:@"wechatNo"];
        
        [list addObject:model];
    }
    return [list copy];
}

@end

@implementation DFCSendGroupModel

+ (NSArray<DFCSendGroupModel *> *)modelListForClassInfo:(NSArray *)classsesInfo
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    DFCSendGroupModel *class = [[DFCSendGroupModel alloc] init];
    // 默认展开
    class.isSelected = YES;
    class.name = @"我的班级";
    class.objectList = [DFCSendObjectModel modelListForClassList:classsesInfo];
    [list addObject:class];
    return list;
}

+ (instancetype)modelForTeacherList:(NSArray *)teachers
{
    DFCSendGroupModel *teacher = [[DFCSendGroupModel alloc] init];
    teacher.name = @"全校教师";
    teacher.objectList = [DFCSendObjectModel modelListForTeacherList:teachers];
    return teacher;
}

@end

//
//  DFCStudentModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCStudentModel.h"

@implementation DFCStudentModel
+(DFCStudentModel*)jsonWithObj:(NSDictionary *)dict{
    if (dict!=nil) {
        DFCStudentModel *model = [[DFCStudentModel alloc]init];
        //dict[@"studentInfo"]  dict[@"schoolInfo"]
            model.address        =  [dict[@"studentInfo"]  objectForKey:@"address"];
            model.birthday        =  [dict[@"studentInfo"]  objectForKey:@"birthday"];
            model.certNo          =  [dict[@"studentInfo"]  objectForKey:@"studentCode"];
            model.imgUrl           =  [dict[@"studentInfo"]  objectForKey:@"imgUrl"];
            model.name            =  [dict[@"studentInfo"]  objectForKey:@"name"];
            model.parentName  =  [dict[@"studentInfo"]  objectForKey:@"parentName"];
            model.qq                 =  [dict[@"studentInfo"]  objectForKey:@"qq"];
            model.tel                 =  [dict[@"studentInfo"]  objectForKey:@"tel"];
            model.schoolCode   =  [dict[@"studentInfo"]  objectForKey:@"schoolCode"];
            model.schoolName   =  [dict[@"schoolInfo"]  objectForKey:@"schoolName"];
            model.studentCode  = [dict[@"schoolInfo"] objectForKey:@"studentCode"];
          model.classJob          =  [dict[@"studentInfo"]  objectForKey:@"classJob"];
          model.year          =  [dict[@"studentInfo"]  objectForKey:@"year"];
          model.className = [dict[@"classInfo"]  objectForKey:@"className"];
          model.seatNo = [dict[@"classInfo"]  objectForKey:@"seatNo"];
        if ([[dict[@"studentInfo"]  objectForKey:@"sex"] isEqualToString:@"M"]) {
            model.sex = @"男";
        } else {
            model.sex = @"女";
        }
        return model;
    }
    return NULL;
}
@end

//
//  DFCClassInfolist.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCClassInfolist.h"

@implementation DFCClassInfolist
+(NSMutableArray*)jsonWithObj{
    //教师所教班级
    //NSArray *list = [[[NSUserDefaultsManager shareManager]getTeacherInfoCache] objectForKey:@"classList"];
    NSMutableArray *arraySource = [[NSMutableArray alloc] init];
    //    for (NSDictionary *dic in list) {
    //        DFCClassInfolist *model = [[self alloc]init];
    //        model.classNick  = [dic objectForKey:@"classNick"];
    //        model.classCode  = [dic objectForKey:@"classCode"];
    //        model.className  = [dic objectForKey:@"className"];
    //        model.roleType   = [dic objectForKey:@"roleType"];
    //        [arraySource addObject:model];
    //    }
    DFCClassInfolist *model = [[DFCClassInfolist alloc]init];
    model.className  = @"一年级一班";
    
    DFCClassInfolist *modela = [[DFCClassInfolist alloc]init];
    modela.className  = @"二年级一班";
    
    DFCClassInfolist *modelb = [[DFCClassInfolist alloc]init];
    modelb.className  = @"三年级一班";
    
    DFCClassInfolist *modelc = [[DFCClassInfolist alloc]init];
    modelc.className  = @"四年级一班";
    
    
    [arraySource addObject:model];
    [arraySource addObject:modela];
    [arraySource addObject:modelb];
    [arraySource addObject:modelc];
    return arraySource;
}

+ (DFCClassInfolist *)jsonWithDic:(NSDictionary *)dic {
    DFCClassInfolist *model = [[DFCClassInfolist alloc]init];
    
    model.className  = dic[@"className"];
    model.classCode = dic[@"classCode"];
    model.classNick = dic[@"classNick"];
    model.roleType = dic[@"stageCode"];
    model.gradeCode = dic[@"stageCode"];
    
    return model;
}

@end

@interface DFCGradeInfolist ()

@property (nonatomic, strong) NSDictionary *gradeDic;

@end

@implementation DFCGradeInfolist

+ (DFCGradeInfolist *)jsonWithDic:(NSDictionary *)dic {
    DFCGradeInfolist *model = [[DFCGradeInfolist alloc]init];
    
    model.gradeCode  = dic[@"stageCode"];
    model.gradeName = [DFCGradeInfolist gradeDic][model.gradeCode];
    
    return model;
}

+ (NSDictionary *)gradeDic {
    return @{
             @"01" : @"一年级",
             @"02" : @"二年级",
             @"03" : @"三年级",
             @"04" : @"四年级",
             @"05" : @"五年级",
             @"06" : @"六年级",
             @"07" : @"七年级",
             @"08" : @"八年级",
             @"09" : @"九年级",
             };
}

+(NSMutableArray*)jsonWithGradeInfoObj{
    //模拟学校所有年级
    //NSArray *list = [[[NSUserDefaultsManager shareManager]getTeacherInfoCache] objectForKey:@"classList"];
    NSMutableArray *arraySource = [[NSMutableArray alloc] init];
    //    for (NSDictionary *dic in list) {
    //        DFCGradeInfolist *model = [[self alloc]init];
    //        model.gradeNick  = [dic objectForKey:@"classNick"];
    //        model.gradeCode  = [dic objectForKey:@"classCode"];
    //        model.gradeName  = [dic objectForKey:@"className"];
    //        [arraySource addObject:model];
    //    }
    DFCGradeInfolist *model = [[DFCGradeInfolist alloc]init];
    model.gradeName  = @"一年级";
    
    DFCGradeInfolist *modela = [[DFCGradeInfolist alloc]init];
    modela.gradeName  = @"二年级";
    
    DFCGradeInfolist *modelb = [[DFCGradeInfolist alloc]init];
    modelb.gradeName  = @"三年级";
    
    DFCGradeInfolist *modelc = [[DFCGradeInfolist alloc]init];
    modelc.gradeName  = @"四年级";
    
    
    [arraySource addObject:model];
    [arraySource addObject:modela];
    [arraySource addObject:modelb];
    [arraySource addObject:modelc];
    
    return arraySource;
}


@end

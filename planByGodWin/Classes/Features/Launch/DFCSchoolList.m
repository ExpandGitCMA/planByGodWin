//
//  DFCSchoolList.m
//  planByGodWin
//
//  Created by 陈美安 on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCSchoolList.h"
#import "DFCHeader_pch.h"
@implementation DFCSchoolList
+(NSArray*)jsonWith:(NSArray *)list{
    NSMutableArray *arraySource = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in list) {
            DFCSchoolList *model = [[self alloc]init];
            model.address            =  [dic objectForKey:@"address"];
            model.schoolCode      =  [dic objectForKey:@"schoolCode"];
            model.schoolName     =  [dic objectForKey:@"schoolName"];
            model.linkman            =  [dic objectForKey:@"linkman"];
            model.linkmanJob       =  [dic objectForKey:@"linkmanJob"];
            model.domainName    =  [dic objectForKey:@"domainName"];
            model.extranetIp        =  [dic objectForKey:@"extranetIp"];
            model.intranetIp         =  [dic objectForKey:@"intranetIp"];
            model.mobile             =  [dic objectForKey:@"mobile"];
            model.modifyTime     =  [dic objectForKey:@"modifyTime"];
            model.password        =  [dic objectForKey:@"password"];
            model.districtCode    =  [dic objectForKey:@"districtCode"];
            [arraySource addObject:model];
        }
       return [arraySource copy];
}

@end

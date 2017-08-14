//
//  DFCTaskModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTaskModel.h"

@implementation DFCTaskModel
+(NSMutableArray*)jsonWithObj:(NSDictionary *)obj{
    if (obj!=nil) {
        NSMutableArray *arraySource = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in obj[@"classroomFileList"]) {
            DFCTaskModel *model = [[DFCTaskModel alloc]init];
            model.fileUrl = [dic objectForKey:@"fileUrl"];
            model.userCode = [dic objectForKey:@"userCode"];
            
            //时间戳转换时间
            NSString *timeStampString  =[NSString stringWithFormat: @"%ld", [[dic objectForKey:@"modifyTime"] integerValue]];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
            NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
            [presentFormat setDateFormat:@"YYYY-MM-dd"];
            model.modifyTime = [presentFormat stringFromDate:date];

            [arraySource addObject:model];
        }
        return arraySource;
    }
    return NULL;
}
@end

//
//  DFCDetailRecordModel.m
//  planByGodWin
//
//  Created by dfc on 2017/5/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDetailRecordModel.h"

@implementation DFCDetailRecordModel
+ (instancetype)detailRecordWithDict:(NSDictionary *)dict{
    DFCDetailRecordModel *detailRecord = [[DFCDetailRecordModel alloc]init];
    detailRecord.detailRecordID = dict[@"id"];
    detailRecord.detailRecordValue = [dict[@"money"] floatValue];
    detailRecord.detailRecordDes = dict[@"note"];
    
    // 创建时间
    NSString *timeStampString  =[NSString stringWithFormat: @"%ld", [[dict objectForKey:@"createTime"] integerValue]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
    [presentFormat setDateFormat:@"YYYY年MM月dd日 HH:mm"];
    detailRecord.detailRecordCreateTime = [presentFormat stringFromDate:date];
    
    return detailRecord;
}
@end

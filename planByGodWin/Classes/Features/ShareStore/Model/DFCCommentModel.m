//
//  DFCCommentModel.m
//  planByGodWin
//
//  Created by dfc on 2017/5/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCommentModel.h"

@implementation DFCCommentModel

+ (instancetype)commentModelWithDict:(NSDictionary *)dict{
    DFCCommentModel *model = [[DFCCommentModel alloc]init];
    model.comment = dict[@"comment"];
    model.coursewareCode = dict[@"coursewareCode"];
    model.authorCode = dict[@"userCode"];
    
    NSString *teacherName = dict[@"teacherName"];
    NSString *studentName = dict[@"studentName"];
    model.authorName = teacherName.length? teacherName : studentName;
    
    NSString *tUrl = dict[@"imgUrl"];
    NSString *sUrl = dict[@"simgUrl"];
    model.authorImgUrl = tUrl.length? tUrl : sUrl;
    
    // 创建时间
    NSString *timeStampString  =[NSString stringWithFormat: @"%ld", [[dict objectForKey:@"modifyTime"] integerValue]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
    [presentFormat setDateFormat:@"YYYY年MM月dd日 HH:mm"];
    model.createDate = [presentFormat stringFromDate:date];
    
    return model;
}

@end

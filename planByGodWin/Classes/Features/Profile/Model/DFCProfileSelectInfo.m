//
//  DFCProfileSelectInfo.m
//  planByGodWin
//
//  Created by zeros on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCProfileSelectInfo.h"

@implementation DFCProfileSelectInfo

+ (NSArray<DFCProfileSelectInfo *> *)ModelListWithInfo:(NSDictionary *)info type:(DFCProfileSelectInfoType)type
{
    NSArray *infoList = nil;
    if (type == DFCProfileSelectInfoTypeClass) {
        infoList = [info objectForKey:@"classList"];
    } else {
        infoList = [info objectForKey:@"coursewareCountInfoList"];
    }
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in infoList) {
        DFCProfileSelectInfo *info = [[DFCProfileSelectInfo alloc] init];
        info.type = type;
        if (type == DFCProfileSelectInfoTypeClass) {
            info.code = [dic objectForKey:@"classCode"];
            info.name = [dic objectForKey:@"className"];
        } else {
            info.code = [dic objectForKey:@"subjectCode"];
            info.name = [dic objectForKey:@"subjectName"];
        }
        [list addObject:info];
    }
    return list;
}

+ (void)ModelList:(NSArray<DFCProfileSelectInfo *> *)modelList MergeInfoList:(NSArray *)infoList
{
    for (NSDictionary *info in infoList) {
        for (DFCProfileSelectInfo *model in modelList) {
            if (model.type == DFCProfileSelectInfoTypeSubject) {
                if ([[info objectForKey:@"subjectCode"] isEqualToString:model.code]) {
                    model.isSelected = YES;
                }
            } else {
                if ([[info objectForKey:@"classCode"] isEqualToString:model.code]) {
                    model.isSelected = YES;
                }
            }
        }
    }
}

@end

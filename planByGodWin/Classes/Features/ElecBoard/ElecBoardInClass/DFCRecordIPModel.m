//
//  DFCRecordIPModel.m
//  planByGodWin
//
//  Created by ZeroSmile on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRecordIPModel.h"

@implementation DFCRecordIPModel

+(DFCRecordIPModel*)parseJsonWithObj:(NSString *)ip{
    DFCRecordIPModel *model = [[DFCRecordIPModel alloc]init];
    model.ip = ip;
    model.code = ip;
    model.userCode =  [[NSUserDefaultsManager shareManager]getAccounNumber];
    [model save];
    return model;
}


+ (NSArray *)propertiesNotInTable {
    return nil;
}

+ (instancetype)dataWithJson:(NSDictionary *)dict {
    return nil;
}
@end

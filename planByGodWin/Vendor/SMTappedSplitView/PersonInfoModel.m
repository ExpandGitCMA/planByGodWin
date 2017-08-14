//
//  PersonInfoModel.m
//  planByGod
//
//  Created by 方沛毅 on 15/12/20.
//  Copyright © 2015年 szcai. All rights reserved.
//

#import "PersonInfoModel.h"

@implementation PersonInfoModel

+ (instancetype)sharedManage {
    static PersonInfoModel *personModel = nil;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        personModel = [[[self class] alloc] init];
    });
    return personModel;
}

@end

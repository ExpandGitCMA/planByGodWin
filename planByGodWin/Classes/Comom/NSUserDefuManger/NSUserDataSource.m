//
//  NSUserDataSource.m
//  planByGodWin
//
//  Created by ZeroSmell on 16/12/6.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "NSUserDataSource.h"

@implementation NSUserDataSource
- (id)copyWithZone:(NSZone *)zone {
    return [[NSUserDataSource allocWithZone:zone] init];
}
+ (id)allocWithZone:(NSZone *)zone{
    return [self sharedInstanceDataDAO];
}

+(instancetype)sharedInstanceDataDAO{
    static dispatch_once_t dispatch;
    static NSUserDataSource *dataDAO = nil;
    dispatch_once(&dispatch , ^{
        if (dataDAO==nil) {
            dataDAO = [[super allocWithZone:NULL] init];
        }
    });
    return dataDAO;
}

-(NSMutableArray*)arrrayController{
    if (!_arrrayController) {
        _arrrayController = [[NSMutableArray alloc]init];
    }
    return _arrrayController;
}

-(void)removeDataAllObjects{
     [ _arrrayController removeAllObjects];
}
@end

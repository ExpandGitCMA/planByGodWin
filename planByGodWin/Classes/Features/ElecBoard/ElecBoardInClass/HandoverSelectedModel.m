//
//  HandoverSelectedModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "HandoverSelectedModel.h"

@implementation HandoverSelectedModel
+(NSArray*)parseJsonWithObj:(NSDictionary*)obj{
    NSString *paths = [[NSBundle mainBundle] pathForResource:@"handover" ofType:@"plist"];
    NSArray *list  = [NSArray arrayWithContentsOfFile:paths];
    NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    for (NSDictionary *dic in list) {
        HandoverSelectedModel *model = [[HandoverSelectedModel alloc]init];
        model.code = [dic objectForKey:@"code"];
        model.titel  = [dic objectForKey:@"titel"];
        model.userCode =  userCode;
        model.url = [dic objectForKey:@"url"];
        [model save];
    }
    return [self findataWithFiles:userCode];
}
+ (NSArray *)propertiesNotInTable {
    return nil;
}

+ (instancetype)dataWithJson:(NSDictionary *)dict {
    return nil;
}

+(NSArray*)findataWithFiles:(NSString*)userCode{
    return [HandoverSelectedModel findByFormat:@"WHERE userCode = '%@' ", userCode];
}

@end

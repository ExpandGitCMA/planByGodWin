//
//  HandoverSelectedModel.h
//  planByGodWin
//  数据层
//  Created by 陈美安 on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

@interface HandoverSelectedModel : DFCDBModel
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *userCode;
@property (nonatomic, copy) NSString *titel;
@property (nonatomic, copy) NSString *url;
@property(nonatomic,assign)BOOL isHide;
+(NSArray*)parseJsonWithObj:(NSDictionary*)obj;
+ (NSArray *)propertiesNotInTable;
+ (instancetype)dataWithJson:(NSDictionary *)dict;
@end

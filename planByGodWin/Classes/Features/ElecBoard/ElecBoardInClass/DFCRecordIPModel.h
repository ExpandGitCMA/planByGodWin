//
//  DFCRecordIPModel.h
//  planByGodWin
//
//  Created by ZeroSmile on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

@interface DFCRecordIPModel : DFCDBModel
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *userCode;
@property (nonatomic, copy) NSString *ip;
+(DFCRecordIPModel*)parseJsonWithObj:(NSString*)ip;
+ (NSArray *)propertiesNotInTable;
+ (instancetype)dataWithJson:(NSDictionary *)dict;

@end

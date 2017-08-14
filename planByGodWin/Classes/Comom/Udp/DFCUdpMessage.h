//
//  DFCUdpMessage.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

@interface DFCUdpMessage : DFCDBModel

@property (nonatomic, strong) NSString *code;

@property (nonatomic, strong) NSString *classCode;
@property (nonatomic, strong) NSString *coursewareCode;
@property (nonatomic, strong) NSString *coursewareName;
@property (nonatomic, strong) NSString *coursewareUrl;
@property (nonatomic, strong) NSString *teacherCode;
@property (nonatomic, strong) NSString *logout;

@property (nonatomic, assign) NSUInteger messageOrder;
@property (nonatomic, assign) NSUInteger pageNo;

//@property (nonatomic, strong) NSString *
//@property (nonatomic, strong) NSString *
+ (instancetype)udpMessageWithDic:(NSDictionary *)dic;

@end

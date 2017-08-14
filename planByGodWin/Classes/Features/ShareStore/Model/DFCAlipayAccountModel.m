//
//  DFCAlipayAccountModel.m
//  planByGodWin
//
//  Created by dfc on 2017/6/1.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAlipayAccountModel.h"

@implementation DFCAlipayAccountModel

+ (instancetype)accountModelWithDict:(NSDictionary *)dict{
    DFCAlipayAccountModel *accountModel = [[DFCAlipayAccountModel alloc]init];
    accountModel.balance = [dict[@"balance"] floatValue];
    accountModel.accountName = dict[@"name"];
    accountModel.accountNum = dict[@"alipayNo"];
    
    return accountModel;
}

@end

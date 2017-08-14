//
//  DFCAlipayAccountModel.h
//  planByGodWin
//
//  Created by dfc on 2017/6/1.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCAlipayAccountModel : NSObject
@property (nonatomic,assign) CGFloat balance;   //  账户余额
@property (nonatomic,copy) NSString *accountName;   // 账户姓名
@property (nonatomic,copy) NSString *accountNum;   // 账号 

+ (instancetype)accountModelWithDict:(NSDictionary *)dict;
@end

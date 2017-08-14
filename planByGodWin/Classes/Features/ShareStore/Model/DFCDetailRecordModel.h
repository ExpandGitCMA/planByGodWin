//
//  DFCDetailRecordModel.h
//  planByGodWin
//
//  Created by dfc on 2017/5/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCDetailRecordModel : NSObject
@property (nonatomic,copy) NSString *detailRecordID;    // 记录id
@property (nonatomic,copy) NSString *detailRecordCreateTime;
@property (nonatomic,assign) NSInteger detailRecordType;    // 收入或支出
@property (nonatomic,copy) NSString *detailRecordDes;   //  说明
@property (nonatomic,assign) CGFloat detailRecordValue; //  金额

+ (instancetype)detailRecordWithDict:(NSDictionary *)dict;
@end

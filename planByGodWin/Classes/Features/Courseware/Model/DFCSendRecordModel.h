//
//  DFCSendRecordModel.h
//  planByGodWin
//
//  Created by zeros on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDBModel.h"

@interface DFCSendRecordModel : DFCDBModel

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *userCode;
@property (nonatomic, copy) NSString *coursewareCode;
@property (nonatomic, copy) NSString *coursewareName;
@property (nonatomic, copy) NSString *netCoverImageUrl;
@property (nonatomic, copy) NSString *objectName;

@end

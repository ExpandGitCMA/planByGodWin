//
//  DFCStudentModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCStudentModel : NSObject
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *certNo;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parentName;
@property (nonatomic, copy) NSString *schoolCode;
@property (nonatomic, copy) NSString *schoolName;
@property (nonatomic, copy) NSString *qq ;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *studentCode;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *classJob;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *classCode ;
@property (nonatomic, copy) NSString *className ;
@property (nonatomic, copy) NSString *seatNo ;
+(DFCStudentModel*)jsonWithObj:(NSDictionary *)dict;
@end

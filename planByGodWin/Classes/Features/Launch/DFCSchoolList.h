//
//  DFCSchoolList.h
//  planByGodWin
//
//  Created by 陈美安 on 16/11/16.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCSchoolList : NSObject
@property(nonatomic,copy)NSString*address;
@property(nonatomic,copy)NSString*createTime;
@property(nonatomic,copy)NSString*deleted;
@property(nonatomic,copy)NSString*districtCode;
@property(nonatomic,copy)NSString*domainName;
@property(nonatomic,copy)NSString*extranetIp;//外网ip
@property(nonatomic,copy)NSString*intranetIp;//内网ip地址
@property(nonatomic,copy)NSString*linkman;
@property(nonatomic,copy)NSString*linkmanJob;
@property(nonatomic,copy)NSString*mobile;
@property(nonatomic,copy)NSString*modifyTime;
@property(nonatomic,copy)NSString*password;
@property(nonatomic,copy)NSString*schoolName;
@property(nonatomic,copy)NSString*schoolCode;

+(NSArray*)jsonWith:(NSArray *)list;

@end

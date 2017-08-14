//
//  PersonInfoModel.h
//  planByGod
//
//  Created by 方沛毅 on 15/12/20.
//  Copyright © 2015年 szcai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USERNAME @"UserName"

@interface PersonInfoModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *qqNum;
@property (nonatomic, copy) NSString *school;
@property (nonatomic, copy) NSString *grade;
@property (nonatomic, copy) NSString *classInfo;
@property (nonatomic, copy) NSString *course;
@property (nonatomic, copy) NSString *identityNum;
@property (nonatomic, copy) NSString *openUserID;

@property (nonatomic, copy) NSString *hideTab;

+ (instancetype)sharedManage;


@end

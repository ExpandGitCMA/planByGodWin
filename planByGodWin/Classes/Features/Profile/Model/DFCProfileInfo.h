//
//  DFCProfileInfo.h
//  planByGodWin
//
//  Created by zeros on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCProfileInfo : NSObject

@property (nonatomic, strong) NSDictionary *baseInfo;

@property (nonatomic, copy) NSString *headImageUrl;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *school;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSArray *subjects;
@property (nonatomic, copy) NSArray *classes;

@property (nonatomic, copy) NSString *subjectsString;
@property (nonatomic, copy) NSString *classesString;

- (instancetype)initWithInfo:(NSDictionary *)info;

- (NSString *)infoForIndex:(NSInteger)index;
- (void)modifyInfoForIndexPath:(NSIndexPath *)indexPath newInfo:(NSString *)newInfo;

@end

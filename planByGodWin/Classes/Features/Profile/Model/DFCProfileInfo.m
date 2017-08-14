//
//  DFCProfileInfo.m
//  planByGodWin
//
//  Created by zeros on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCProfileInfo.h"

@implementation DFCProfileInfo

- (instancetype)initWithInfo:(NSDictionary *)info
{
    if (self = [super init]) {
        NSDictionary *personInfo = [info objectForKey:@"teacherInfo"];
        NSString *sex = nil;
        if ([[personInfo objectForKey:@"sex"] isEqualToString:@"M"]) {
            sex = @"男";
        } else {
            sex = @"女";
        }
        NSDictionary *schoolInfo = [info objectForKey:@"schoolInfo"];

        self.headImageUrl = [personInfo objectForKey:@"imgUrl"];
        self.account = [personInfo objectForKey:@"teacherCode"];
        self.name = [personInfo objectForKey:@"name"];
        self.gender = sex;
        self.phoneNumber = [personInfo objectForKey:@"mobile"];
        self.school = [schoolInfo objectForKey:@"schoolName"];
        NSString *birthStr = [personInfo objectForKey:@"birthday"];
        self.birthday = [NSString stringWithFormat:@"%@.%@.%@",[birthStr substringWithRange:NSMakeRange(0, 4)], [birthStr substringWithRange:NSMakeRange(4, 2)], [birthStr substringFromIndex:6]];
        self.subjects = [info objectForKey:@"subjectList"];
        self.classes = [info objectForKey:@"classList"];
    }
    return self;
}

- (NSDictionary *)baseInfo{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info setValue:_headImageUrl forKey:@"imgUrl"];
    [info setValue:_name forKey:@"name"];
    [info setValue:_phoneNumber forKey:@"mobile"];
    return [info copy];
}

- (NSString *)subjectsString
{
    NSMutableString *subjects = [[NSMutableString alloc] init];
    for (NSDictionary *info in _subjects) {
        [subjects appendFormat:@" %@", [info objectForKey:@"subjectName"]];
    }
    return [subjects copy];
}

- (NSString *)classesString
{
    NSMutableString *classes = [[NSMutableString alloc] init];
    for (NSDictionary *info in _classes) {
        [classes appendFormat:@" %@", [info objectForKey:@"className"]];
    }
    return [classes copy];
}

- (NSString *)infoForIndex:(NSInteger)index
{
    NSString *info = nil;
    switch (index) {
        case 0:
        {
            break;
        }
        case 1:
        {
            info = self.name;
            break;
        }
        case 2:
        {
            
            break;
        }
        case 3:
        {
            break;
        }
        case 4:
        {
            info = self.phoneNumber;
            break;
        }
        case 5:
        {
//            info = self.birthday;
            break;
        }
        case 6:
        {
            
            break;
        }
        case 7:
        {
            break;
        }
        case 8:
        {
            break;
        }
            
        default:
            break;
    }
    return info;
}

- (void)modifyInfoForIndexPath:(NSIndexPath *)indexPath newInfo:(NSString *)newInfo
{
    switch (indexPath.row) {
        case 0:
        {
            break;
        }
        case 1:
        {
            self.name = newInfo;
            break;
        }
        case 2:
        {
            
            break;
        }
        case 3:
        {
            break;
        }
        case 4:
        {
            
            self.phoneNumber = newInfo;
            break;
        }
        case 5:
        {
            break;
        }
        case 6:
        {
            break;
        }
        case 7:
        {
            break;
        }
        case 8:
        {
            break;
        }
            
        default:
            break;
    }
}

@end

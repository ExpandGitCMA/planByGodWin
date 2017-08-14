//
//  DFCUtility.m
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCUtility.h"

@implementation DFCUtility

+ (BOOL)isValidPhoneNum:(NSString *)phoneNum{
    NSString *regex = @"1[0-9]{10}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:phoneNum];
}

+ (BOOL)isNumber:(NSString *)string{
    NSString *regex = @"^[0－9]*$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:string];
}

+ (BOOL)isNumberID:(NSString *)string{
    NSString *regex = @"^[0－9xX]*$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:string];
}

+ (BOOL)isNumberAndCharter:(NSString *)string{
    NSString *regex = @"^[a-z0－9A-Z]*$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:string];
}

+ (BOOL)isIegalCharter:(NSString *)string{
    NSString *regex = @"^[a-z0－9A-Z\u4e00-\u9fa5]*$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:string];
}

+ (BOOL)isCurrentTeacher {
    return ![[NSUserDefaultsManager shareManager]isUserMark];
}

+ (NSString *)get_uuid {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

@end

//
//  NSUserBlankSimple.m
//  planByGodWin
//
//  Created by Zero on 16/11/26.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "NSUserBlankSimple.h"

static NSUserBlankSimple *blankSimple = nil;

@implementation NSUserBlankSimple

- (id)copyWithZone:(NSZone *)zone {
    return [[NSUserBlankSimple allocWithZone:zone] init];
}

+ (id)allocWithZone:(NSZone *)zone{
   return [self shareBlankSimple];
}

+(NSUserBlankSimple *)shareBlankSimple{
    static dispatch_once_t dispatch;
    dispatch_once(&dispatch, ^{
        blankSimple = [[super allocWithZone:NULL] init];
    });
    return blankSimple;
}


/*
 *@计算当前系统时间
 *@ Day 2016.11.26
 */
-(NSDateComponents*)getNonceComponents{
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear
                                               fromDate:nowDate];
    return components;
}

-(NSInteger)nowayear{
    NSInteger year = [[self getNonceComponents]year];
    return year;
}
-(NSInteger)nowamonth{
    NSInteger month = [[self getNonceComponents]month];
    return month;
}
-(NSInteger)nowaday{
    NSInteger day = [[self getNonceComponents]day];
    return day;
}
-(NSInteger)nowahour{
    NSInteger hour = [[self getNonceComponents]hour];
    return hour;
}
-(NSInteger)nowaminute{
    NSInteger minute = [[self getNonceComponents]minute];
    return minute;
}
-(NSInteger)nowasecond{
    NSInteger second = [[self getNonceComponents]second];
    return second;
}

/*
 *@当前星期几
 */
-(NSInteger)nowaweekday{
    NSInteger weekday = [[self getNonceComponents]weekday]-1;
    return weekday;
}
/*
 *@当前周是在当月的第几周
 */
-(NSInteger)nowaweekdayOrdinal{
    NSInteger weekdayOrdinal = [[self getNonceComponents]weekdayOrdinal];
    return weekdayOrdinal;
}
/*
 *@当前今年的第几周
 */
-(NSInteger)nowaweek{
    NSInteger week = [[self getNonceComponents]weekday];
    return week;
}

//判断数组是否为空
-(BOOL)isExist:(NSArray*)arraySource{
    if ([arraySource count]==0||arraySource == nil) {
        return NO;
    }else{
        return YES;
    }
}
//判断字符串是否为空
- (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}


@end

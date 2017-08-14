//
//  DFCDateHelp.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/26.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCDateHelp.h"

@implementation DFCDateHelp

+ (NSString *)currentDate {
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY年MM月dd日";
//    formatter.dateFormat = @"YYYY-MM-DD";// HH:mm:ss
    
    return [formatter stringFromDate:date];
}

@end

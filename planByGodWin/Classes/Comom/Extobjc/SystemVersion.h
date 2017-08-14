//
//  SystemVersion.h
//  IM_Expensive
//
//  Created by 蔡士章 on 15/10/2.
//  Copyright © 2015年 szcai. All rights reserved.
//
//判断系统版本
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 * 检查运行时版本是否至少为某一版本
 */
BOOL RuntimeOSVerionIsAtLeast(float version);

/**
 * @return 设备完整的model
 */
NSString * DeviceModelName();

@interface SystemVersion : NSObject

@end

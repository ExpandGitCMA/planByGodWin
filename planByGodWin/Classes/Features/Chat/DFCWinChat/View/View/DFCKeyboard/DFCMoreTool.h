//
//  DFCMoreTool.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCMoreTool : NSObject
@property(nonatomic,copy)NSString*tool;
@property(nonatomic,copy)NSString*titel;
+(NSMutableArray*)jsonWithTool;
@end

//
//  DFCTaskModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCTaskModel : NSObject
@property (nonatomic, copy) NSString *fileUrl ;
@property (nonatomic, copy) NSString *modifyTime;
@property (nonatomic, copy) NSNumber *userCode ;
+(NSMutableArray*)jsonWithObj:(NSDictionary*)obj;
@end

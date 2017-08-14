//
//  NSUserBlankSimple.h
//  planByGodWin
//
//  Created by Zero on 16/11/26.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserBlankSimple : NSObject<NSCopying>
+(NSUserBlankSimple *)shareBlankSimple;
-(BOOL)isExist:(NSArray*)arraySource;
- (BOOL)isBlankString:(NSString *)string;

@end

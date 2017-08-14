//
//  DFCCreateFileModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCCreateFileModel : NSObject
@property (nonatomic, copy) NSString *titel;
@property (nonatomic, copy) NSString *url;
+(NSArray*)parseJsonWithObj;
@end

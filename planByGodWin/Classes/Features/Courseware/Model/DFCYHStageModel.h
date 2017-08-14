//
//  DFCYHStageModel.h
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCYHStageModel : NSObject
@property (nonatomic,copy) NSString *stageName;
@property (nonatomic,copy) NSString *stageCode;
+ (instancetype)stageModelWithDict:(NSDictionary *)dict;
@end

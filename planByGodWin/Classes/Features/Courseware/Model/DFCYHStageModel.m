//
//  DFCYHStageModel.m
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCYHStageModel.h"

@implementation DFCYHStageModel
+ (instancetype)stageModelWithDict:(NSDictionary *)dict{
    DFCYHStageModel *stageModel = [[DFCYHStageModel alloc]init];
    stageModel.stageName = dict[@"stageName"];
    stageModel.stageCode = dict[@"stageCode"];
    return stageModel;
}
@end

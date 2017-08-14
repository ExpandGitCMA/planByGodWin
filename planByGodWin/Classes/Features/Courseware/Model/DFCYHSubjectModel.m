//
//  DFCYHSubjectModel.m
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCYHSubjectModel.h"

@implementation DFCYHSubjectModel
+ (instancetype)subjectModelWithDict:(NSDictionary *)dict{
    DFCYHSubjectModel *subjectModel = [[DFCYHSubjectModel alloc]init];
    subjectModel.subjectName  = dict[@"subjectName"];
    subjectModel.subjectCode = dict[@"subjectCode"];
    return subjectModel;
}
@end

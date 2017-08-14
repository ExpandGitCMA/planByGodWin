//
//  DFCYHSubjectModel.h
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCYHSubjectModel : NSObject
@property (nonatomic,copy) NSString *subjectName;
@property (nonatomic,copy) NSString *subjectCode;
+ (instancetype)subjectModelWithDict:(NSDictionary *)dict;
@end

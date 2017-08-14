//
//  DFCAirDropCourseware_m
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/1.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAirDropCoursewareModel.h"
#import "DFCCoursewareModel.h"

@implementation DFCAirDropCoursewareModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:@"_title"];
        _coursewareCode = [aDecoder decodeObjectForKey:@"_coursewareCode"];
        _userCode = [aDecoder decodeObjectForKey:@"_userCode"];
        _code = [aDecoder decodeObjectForKey:@"_code"];
        _coverImageUrl = [aDecoder decodeObjectForKey:@"_coverImageUrl"];
        _fileUrl = [aDecoder decodeObjectForKey:@"_fileUrl"];
        _netUrl = [aDecoder decodeObjectForKey:@"_netUrl"];
        _fileSize = [aDecoder decodeObjectForKey:@"_fileSize"];
        _time = [aDecoder decodeObjectForKey:@"_time"];
        _netCoverImageUrl = [aDecoder decodeObjectForKey:@"_netCoverImageUrl"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:@"_title"];
    [aCoder encodeObject:_coursewareCode forKey:@"_coursewareCode"];
    [aCoder encodeObject:_userCode forKey:@"_userCode"];
    [aCoder encodeObject:_code forKey:@"_code"];
    [aCoder encodeObject:_coverImageUrl forKey:@"_coverImageUrl"];
    [aCoder encodeObject:_fileUrl forKey:@"_fileUrl"];
    [aCoder encodeObject:_fileSize forKey:@"_fileSize"];
    [aCoder encodeObject:_time forKey:@"_time"];
    [aCoder encodeObject:_netUrl forKey:@"_netUrl"];
    [aCoder encodeObject:_netCoverImageUrl forKey:@"_netCoverImageUrl"];
}

- (DFCCoursewareModel *)coursewareModel {
    DFCCoursewareModel *model = [DFCCoursewareModel new];
    
    model.title = self.title;
    model.coursewareCode = self.coursewareCode;
    model.userCode = self.userCode;
    model.code = self.code;
    model.coverImageUrl = self.coverImageUrl;
    model.fileUrl = self.fileUrl;
    model.fileSize = self.fileSize;
    model.time = self.time;
    model.netUrl = self.netUrl;
    model.netCoverImageUrl = self.netCoverImageUrl;
    
    return model;
}

@end

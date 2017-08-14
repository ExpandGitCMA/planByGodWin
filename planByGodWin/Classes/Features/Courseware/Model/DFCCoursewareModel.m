//
//  DFCCoursewareModel.m
//  planByGodWin
//
//  Created by zeros on 17/1/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareModel.h"
#import "DFCAirDropCoursewareModel.h"

@implementation DFCCoursewareModel

+ (instancetype)coursewareModelWithDic:(NSDictionary *)dict{
    DFCCoursewareModel *coursewareModel = [[DFCCoursewareModel alloc]init];
    coursewareModel.coursewareCode = dict[@"coursewareCode"];
    coursewareModel.title = dict[@"coursewareName"];
    
    NSArray *thumbUrls = [dict[@"thumbUrl"] componentsSeparatedByString:@";"];
    coursewareModel.netCoverImageUrl = thumbUrls.firstObject;
    coursewareModel.thumbnailsImgNames = thumbUrls;
    
    coursewareModel.netUrl = dict[@"url"];
    coursewareModel.isSelected = NO;    // 默认不选中
    
    //时间戳转换时间
    NSString *timeStampString  =[NSString stringWithFormat: @"%ld", [[dict objectForKey:@"createTime"] integerValue]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStampString doubleValue] / 1000];
    NSDateFormatter *presentFormat  = [[NSDateFormatter alloc] init];
    [presentFormat setDateFormat:@"YYYY年MM月dd日"];
    coursewareModel.time = [presentFormat stringFromDate:date];
    
    return coursewareModel;
}

+ (NSArray<DFCCoursewareModel *> *)listFromDownloadCoursewareInfo:(NSDictionary *)info
{
    NSArray *exitList = [DFCCoursewareModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *listInfo = [info objectForKey:@"coursewareInfoList"];
    DEBUG_NSLog(@"课件下载===%@",listInfo);
    for (NSDictionary *dic in listInfo) {
        DFCCoursewareModel *model = [[DFCCoursewareModel alloc] init];
        model.title = [dic objectForKey:@"coursewareName"];
        model.coursewareCode = [dic objectForKey:@"coursewareCode"];
        // modify by hmy
        model.code = [NSString stringWithFormat:@"%@%@", model.coursewareCode, [DFCUserDefaultManager getAccounNumber]]; //model.coursewareCode; //
        model.userCode = [DFCUserDefaultManager getAccounNumber];
        model.netUrl = [dic objectForKey:@"url"];
        model.netCoverImageUrl = [dic objectForKey:@"thumbUrl"];
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCCoursewareModel *model1 = (DFCCoursewareModel *)evaluatedObject;
            return [model1.coursewareCode isEqualToString:model.coursewareCode];
        }];
        NSArray *ret = [exitList filteredArrayUsingPredicate:predicate];
        if (ret.count) {
            model.type = DFCCoursewareModelTypeDownloaded;
        }
        [list addObject:model];
    }
    return [list copy];
}

- (id)copyWithZone:(NSZone *)zone {
    DFCCoursewareModel *model = [DFCCoursewareModel new];
    
    model.title = self.title;
    model.coursewareCode = self.coursewareCode;
    model.userCode = self.userCode;
    model.code = self.coursewareCode;
    model.coverImageUrl = self.coverImageUrl;
    model.fileUrl = self.fileUrl;
    model.fileSize = self.fileSize;
    model.title = self.title;
    model.time = self.time;

    return model;
}

- (DFCAirDropCoursewareModel *)airDropModel {
    DFCAirDropCoursewareModel *model = [DFCAirDropCoursewareModel new];
    
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


+ (NSArray *)propertiesNotInTable
{
    return @[@"isSelected", @"type", @"progress", @"speed", @"sendObject"];
}

@end

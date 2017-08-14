//
//  DFCCloudFileModel.m
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudFileModel.h"

@implementation DFCCloudFileModel

- (void)setNetUrl:(NSString *)netUrl
{
    _netUrl = netUrl;
    _code = netUrl;
}

+ (NSString *)folderForCloudFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *finalPath = [docDir stringByAppendingPathComponent:@"cloudFile"];
    return finalPath;
}

//+ (NSArray<DFCCloudFileModel *> *)listFromDownloadInfo:(NSDictionary *)info
//{
//    NSArray *exitList = [DFCCloudFileModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
//    NSMutableArray *list = [[NSMutableArray alloc] init];
//    NSArray *infoList = [info objectForKey:@"fileInfoList"];;
//    for (NSDictionary *dic in infoList) {
//        DFCCloudFileModel *model = [[DFCCloudFileModel alloc] init];
//        model.code = [dic objectForKey:@"filePath"];
//        model.fileName = [dic objectForKey:@"fileName"];
//        model.userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
//        NSString *filePath = [dic objectForKey:@"filePath"];
//        model.netUrl = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        model.fileType = [dic objectForKey:@"fileType"];
//        [list addObject:model];
//        for (DFCCloudFileModel *downloaded in exitList) {
//            if ([[NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl] isEqualToString:downloaded.netUrl]) {
//                 model.fileUrl = downloaded.fileUrl;
//            }
//        }
//        [model save];
//    }
//    return [list copy];
//}

+ (NSArray<DFCCloudFileModel *> *)listFromDownloadInfo:(NSDictionary *)info
{
    NSArray *exitList = [DFCCloudFileModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray *infoList = [info objectForKey:@"fileInfoList"];
    for (NSDictionary *dic in infoList) {
        DFCCloudFileModel *model = [[DFCCloudFileModel alloc] init];
        model.code = [dic objectForKey:@"filePath"];
        model.fileName = [dic objectForKey:@"fileName"];
        model.userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
        NSString *filePath = [dic objectForKey:@"filePath"];
        model.netUrl = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // add by hmy  webppt本地
        if ([filePath hasSuffix:@"html"]) {
            NSString *netUrl = model.netUrl;
            netUrl = [netUrl stringByDeletingLastPathComponent];
            model.netUrl = [netUrl stringByAppendingString:@".zip"];
        }
        
        model.fileType = [dic objectForKey:@"fileType"];
        [list addObject:model];
        for (DFCCloudFileModel *downloaded in exitList) {
            if ([[NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl] isEqualToString:downloaded.netUrl]) {
                model.fileUrl = downloaded.fileUrl;
                model.downloaded = YES;
            }
        }
        [model save];
    }
    return [list copy];
}
+ (NSArray *)propertiesNotInTable
{
    return @[@"isSelected"];
}
+(NSArray<DFCCloudFileModel *>*)parseJson:(NSArray *)obj{
    NSMutableArray*list = [NSMutableArray new];
    for (NSDictionary *dic in obj) {
        DFCCloudFileModel *model = [[DFCCloudFileModel alloc] init];
        NSNumber *myNumber = [dic objectForKey:@"id"];
        model.page = [myNumber intValue];
        model.fileName = [dic objectForKey:@"dirName"];
        [list addObject:model];
    }
    return [list copy];
}

@end

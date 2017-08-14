//
//  DFCCreateFileModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCreateFileModel.h"

@implementation DFCCreateFileModel
+(NSArray*)parseJsonWithObj{
    NSString *paths = [[NSBundle mainBundle] pathForResource:@"createFile" ofType:@"plist"];
    NSArray *list  = [NSArray arrayWithContentsOfFile:paths];
    NSMutableArray*arraySource = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in list) {
      DFCCreateFileModel *model = [[DFCCreateFileModel alloc]init];
        model.titel  = [dic objectForKey:@"titel"];
        model.url = [dic objectForKey:@"url"];
        [arraySource addObject:model];
    }
    return [arraySource copy];
}
@end

//
//  DFCMoreTool.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMoreTool.h"

@implementation DFCMoreTool
+(NSMutableArray*)jsonWithTool{
    NSString *paths = [[NSBundle mainBundle] pathForResource:@"moreTool" ofType:@"plist"];
    NSArray *list  = [NSArray arrayWithContentsOfFile:paths];
    NSMutableArray*arraySource = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in list) {
        DFCMoreTool *model = [[DFCMoreTool alloc]init];
        model.tool = [dic objectForKey:@"tool"];
        model.titel  = [dic objectForKey:@"title"];
        [arraySource addObject:model];
    }
    return arraySource;
}
@end

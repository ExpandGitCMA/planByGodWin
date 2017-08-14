//
//  DFC_EDResourceItem.m
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFC_EDResourceItem.h"

@implementation DFC_EDResourceItem

/**
 获取自定义素材模型
 */
+ (instancetype)resourceItemWithDict:(NSDictionary *)dict{
    DFC_EDResourceItem *item = [[DFC_EDResourceItem alloc]init];
    item.itemID = dict[@"id"];
    item.path = dict[@"faceUrl"];
    
    return item;
}
@end

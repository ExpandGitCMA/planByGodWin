//
//  DFC_EDResourceItem.h
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFC_EDResourceItem : NSObject

@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,assign) BOOL selected; // 是否选中
@property (nonatomic,assign) BOOL editable; // 是否可编辑删除
//@property (nonatomic,assign) NSInteger type;
@property (nonatomic,copy) NSString *itemID;
@property (nonatomic,assign) BOOL downloaded;   // 自定义素材是否已经下载（未下载）

+ (instancetype)resourceItemWithDict:(NSDictionary *)dict;

@end

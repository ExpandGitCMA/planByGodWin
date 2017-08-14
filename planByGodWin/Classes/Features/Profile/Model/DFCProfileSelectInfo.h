//
//  DFCProfileSelectInfo.h
//  planByGodWin
//
//  Created by zeros on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DFCProfileSelectInfoType) {
    DFCProfileSelectInfoTypeSubject,
    DFCProfileSelectInfoTypeClass
};

@interface DFCProfileSelectInfo : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) DFCProfileSelectInfoType type;

+ (NSArray<DFCProfileSelectInfo *> *)ModelListWithInfo:(NSDictionary *)info type:(DFCProfileSelectInfoType)type;
+ (void)ModelList:(NSArray<DFCProfileSelectInfo *> *)modelList MergeInfoList:(NSArray *)infoList;

@end

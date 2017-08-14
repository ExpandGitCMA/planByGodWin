//
//  DFCBaseViewInfo.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCBaseViewInfo : NSObject

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isScaleLocked;
@property (nonatomic, assign) BOOL isMoveLocked;

@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, assign) NSUInteger currentLayer;

@end

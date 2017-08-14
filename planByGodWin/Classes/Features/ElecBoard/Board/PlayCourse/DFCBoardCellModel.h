//
//  DFCBoardModel.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCBoardCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *taskOrder;
@property (nonatomic, copy) NSString *taskOrd;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL canEdit;

@end

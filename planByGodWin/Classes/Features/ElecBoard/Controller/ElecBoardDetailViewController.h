//
//  ElecBoardDetailViewController.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/9/7.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCElecBoardView.h"
#import "DFCCoursewareModel.h"

@class DFCBoard;

@interface ElecBoardDetailViewController : UIViewController
/**
 *  新建类型或者编辑类型
 */
@property (nonatomic, assign) ElecBoardType type;

@property (nonatomic, assign) kElecBoardOpenType openType;

/**
 *  board
 */
@property (nonatomic, strong) DFCBoard *board;
/**
 *  当前是第几个场景
 */
//@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) DFCCoursewareModel *coursewareModel;


/**
 *  本地文件路径
 */
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) DFCElecBoardView *elecView;
@property (nonatomic, strong) NSString *teacherCode;
@property (nonatomic, strong) NSString *coursewareCode;
@property (nonatomic, strong) NSString *classCode;
@property (nonatomic, copy) NSString *color;

@end

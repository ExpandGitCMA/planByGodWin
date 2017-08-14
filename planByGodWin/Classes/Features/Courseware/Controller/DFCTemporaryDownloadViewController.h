//
//  DFCTemporaryDownloadViewController.h
//  planByGodWin
//
//  Created by zeros on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCCoursewareModel;

@interface DFCTemporaryDownloadViewController : UIViewController

- (instancetype)initWithCourseware:(DFCCoursewareModel *)model;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, copy) dispatch_block_t finishBlock;

@end

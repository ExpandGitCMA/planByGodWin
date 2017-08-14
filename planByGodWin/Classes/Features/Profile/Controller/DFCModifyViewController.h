//
//  DFCModifyViewController.h
//  planByGodWin
//
//  Created by zeros on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCProfileInfo;
@class DFCStudentModel;

@interface DFCModifyViewController : UIViewController

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath info:(DFCProfileInfo *)info;
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath studentInfo:(DFCStudentModel *)info;

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath studentInfo:(DFCStudentModel *)info;

- (void)confirmModify: (void(^)(NSString *newInfo))block;

@end

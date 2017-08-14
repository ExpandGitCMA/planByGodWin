//
//  DFCStudentListsViewController.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCBaseViewController.h"
#import "DFCGropMemberModel.h"

@class DFCStudentListsViewController;
@class DFCStudentWorksViewController;

@protocol DFCStudentListsViewControllerDelegate <NSObject>

- (void)studentWorksViewController:(DFCStudentWorksViewController *)vc
                  didSelectStudent:(DFCGroupClassMember *)student
                             image:(NSString *)imgUrl
                             index:(NSUInteger)index;

@end

@interface DFCStudentListsViewController : DFCBaseViewController

@property (nonatomic, assign) id<DFCStudentListsViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *classCode;

- (void)pushStudentWorksController;
- (void)hasStudentConnect:(NSNotification *)noti;

@end

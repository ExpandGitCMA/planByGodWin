//
//  DFCStudentWorksViewController.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCBaseViewController.h"
#import "DFCGropMemberModel.h"

@class DFCStudentWorksViewController;

@protocol DFCStudentWorksViewControllerDelegate <NSObject>

- (void)studentWorksViewControllerDidBack:(DFCStudentWorksViewController *)vc;
- (void)studentWorksViewController:(DFCStudentWorksViewController *)vc
                    didSelectImage:(NSString *)imgUrl
                             index:(NSUInteger)index;
@end

@interface DFCStudentWorksViewController : DFCBaseViewController

@property (nonatomic, assign) id<DFCStudentWorksViewControllerDelegate> delegate;

@property (nonatomic, copy) DFCGroupClassMember *student;

@end

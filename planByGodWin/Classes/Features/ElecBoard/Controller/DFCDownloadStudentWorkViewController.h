//
//  DFCDownloadStudentWorkViewController.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCBaseViewController.h"
#import "DFCGropMemberModel.h"

@class DFCDownloadStudentWorkViewController;

@protocol DFCDownloadStudentWorkViewControllerDelegate <NSObject>

- (void)downloadStudentWorkViewControllerDidBack:(DFCDownloadStudentWorkViewController *)vc;
- (void)downloadStudentWorkViewController:(DFCDownloadStudentWorkViewController *)vc
                              didAddImage:(UIImage *)image;
@end

@interface DFCDownloadStudentWorkViewController : DFCBaseViewController

@property (nonatomic, assign) id<DFCDownloadStudentWorkViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) DFCGroupClassMember *student;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

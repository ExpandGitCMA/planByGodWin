//
//  DFCInClassBaseViewController.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCInClassBaseViewController;

@protocol DFCInClassBaseViewControllerDelegate <NSObject>

@optional
- (void)elecBoardInClassViewControllerDidOnClass:(DFCInClassBaseViewController *)vc
                                       classCode:(NSString *)classCode playConnection:(NSString*)playConnection;
- (void)elecBoardInClassViewControllerDidLeaveClass:(DFCInClassBaseViewController *)vc;

- (void)elecBoardInClassViewControllerDidTapSaveAndUploadForName:(NSString *)name;

@end

@interface DFCInClassBaseViewController : UIViewController

@property (nonatomic, assign) id<DFCInClassBaseViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *coursewareCode;
@property (nonatomic, strong) NSString *coursewareName;
@property (nonatomic, assign) BOOL hasBeenEdited;

@end

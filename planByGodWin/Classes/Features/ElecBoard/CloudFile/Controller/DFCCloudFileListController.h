//
//  DFCCloudFileListController.h
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCCloudFileModel.h"

@protocol DFCCloudFileListControllerDelegate <NSObject>

- (void)cloudFileListControllerDidInsertFile:(DFCCloudFileModel *)cloudFile;

@end

@interface DFCCloudFileListController : UIViewController

@property (nonatomic, weak) id <DFCCloudFileListControllerDelegate> delegate;

@end

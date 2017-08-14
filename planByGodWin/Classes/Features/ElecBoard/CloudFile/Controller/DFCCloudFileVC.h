//
//  DFCCloudFileVC.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/2.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudFileListController.h"
#import "DFCCloudFileModel.h"

@protocol DidCloudFileDelegate <NSObject>
@optional
- (void)didCloudFile:(DFCCloudFileModel *)model;
- (void)didInsertFile:(id)sender;
@end

@interface DFCCloudFileVC : UIViewController
-(instancetype)initWithTitel:(NSString*)titel  page:(int)page delegate:(id<DidCloudFileDelegate>)delgate;
@end

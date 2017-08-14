//
//  DFCCloudFileView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/2/28.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCCloudFileModel.h"

@protocol DFCCloudFileDelegate <NSObject>
@optional
- (void)didSelectCloudFile:(DFCCloudFileModel *)model;
@end

@interface DFCCloudFileView : UIView

-(instancetype)initWithFrame:(CGRect)frame page:(int)page delegate:(id<DFCCloudFileDelegate>)delgate;
@end

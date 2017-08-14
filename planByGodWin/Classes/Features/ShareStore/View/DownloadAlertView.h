//
//  DownloadAlertView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodSubjectProtocol.h"
@interface DownloadAlertView : UIView
@property(nonatomic,retain) UILabel *progress;
@property (nonatomic, weak) id<DFCGoodSubjectProtocol>protocol;
-(instancetype)initWithMessage:(NSString *)message sure:(NSString *)sureTitle cancle:(NSString *)cancle;
-(instancetype)initWithDownloadAlertView;
-(void)showAlertView;
-(instancetype)initWithShowAlertViewDelay:(NSTimeInterval)delay;
@end

//
//  DFCHeadButtonView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodSubjectProtocol.h"

@interface DFCHeadButtonView : UIView
@property (nonatomic, weak) id<DFCGoodSubjectProtocol>protocol;
+(DFCHeadButtonView*)initWithDFCHeadButtonView;
+(DFCHeadButtonView*)initWithAddSubviewGoodsUpload;
@end

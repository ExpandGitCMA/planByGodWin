//
//  GoodPageUpView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGoodSubjectProtocol.h"

@interface GoodPageUpView : UIView
@property (nonatomic, weak) id<DFCGoodSubjectProtocol>protocol;
+(GoodPageUpView*)initWithFrame:(CGRect)frame;
@property (weak, nonatomic) IBOutlet UILabel *titel;
@end

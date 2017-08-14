//
//  DFCProfileView.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCBaseView.h"

@interface DFCMyProfileView : UIView<NSCoding>

+ (instancetype)profileViewWithFrame:(CGRect)frame;

@property (weak, nonatomic) IBOutlet UIImageView *studentIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *studentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceCodeLabel;

@end

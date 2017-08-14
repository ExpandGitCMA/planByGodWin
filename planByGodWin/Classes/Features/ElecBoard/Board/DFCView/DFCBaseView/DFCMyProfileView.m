//
//  DFCProfileView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMyProfileView.h"

@interface DFCMyProfileView ()


@end

@implementation DFCMyProfileView

+ (instancetype)profileViewWithFrame:(CGRect)frame {
    DFCMyProfileView *profileView = [[[NSBundle mainBundle] loadNibNamed:@"DFCMyProfileView" owner:self options:nil] firstObject];
    profileView.frame = frame;
    return profileView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.studentCodeLabel DFC_setLabelLayerCorner];
    [self.studentNameLabel DFC_setLabelLayerCorner];
    [self.deviceCodeLabel DFC_setLabelLayerCorner];
    [self.studentIconImageView DFC_setSelectedLayerCorner];
    self.studentIconImageView.layer.cornerRadius = 30.0f;
}

@end

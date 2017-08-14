
//
//  UIView+DFCLayerCorner.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/21.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "UIView+DFCLayerCorner.h"

@implementation UIView (DFCLayerCorner)

- (void)DFC_setLayerCorner {
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [kUIColorFromRGB(BoardLineColor) CGColor];
    self.layer.borderWidth = 1.0f;
}

- (void)DFC_setLabelLayerCorner {
    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [[UIColor clearColor] CGColor];
    self.layer.borderWidth = 1.0f;
}

- (void)DFC_setSliderLayerCorner {
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 3;
    self.layer.borderColor = [kUIColorFromRGB(0x434343) CGColor];
}

- (void)DFC_setSelectedLayerCorner {
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [kUIColorFromRGB(ButtonGreenColor) CGColor];
    self.layer.borderWidth = 1.0f;
}

- (void)DFC_setPageSynopsisView {
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [[UIColor clearColor] CGColor];
    self.layer.borderWidth = 1.0f;
}

@end

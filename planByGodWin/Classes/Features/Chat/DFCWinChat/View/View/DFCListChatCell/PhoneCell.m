//
//  PhoneCell.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "PhoneCell.h"

@implementation PhoneCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.head.layer.cornerRadius = 30;
     self.head.layer.masksToBounds = YES;
   // self.head.contentMode = UIViewContentModeScaleAspectFit;
    
    self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.frame];
    //
     self.selectedBackgroundView.backgroundColor = kUIColorFromRGB(MessgelColor);
    [self.selectedBackgroundView cornerRadius:5 borderColor:[[UIColor clearColor] CGColor] borderWidth:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

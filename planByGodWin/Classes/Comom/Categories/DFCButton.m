//
//  DFCButton.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCButton.h"

@implementation DFCButton
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        
    }
    return self;
}
-(void)setKey:(SubkeyButtonType)Key{
    switch (Key) {
        case Subkeylogin:{
            [self setButtonNormalStyle];
            [self setBackgroundColor:kUIColorFromRGB(ButtonTypeColor)];
            self.titleLabel.font = [UIFont systemFontOfSize:15];
        }
            break;
        case Subkeyrecord:{
            self.titleLabel.font = [UIFont systemFontOfSize:15];
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        }break;
        case SubkeyUserName:{
              self.titleLabel.font = [UIFont systemFontOfSize:15];
              [self setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
        }break;
        case SubkeyUserImage:{
            self.contentMode =  UIViewContentModeLeft;
            self.showsTouchWhenHighlighted = YES;
        }break;
        case SubkeyEdgeInsets:{
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.titleLabel.font = [UIFont systemFontOfSize:16];
            self.showsTouchWhenHighlighted = YES;
            [self setBackgroundColor:[UIColor whiteColor]];
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            self.imageView.contentMode = UIViewContentModeCenter;
            self.imageView.clipsToBounds = NO;
        }break;
        case SubkeyUpload:{
            [self setButtonUploadStyle];
            [self setBackgroundColor:kUIColorFromRGB(0xe7e7e7)];
        }break;
        case SubkeyPay:{
           
        }break;
        default:
            break;
    }

}



@end

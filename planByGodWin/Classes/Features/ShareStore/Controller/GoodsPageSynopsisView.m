//
//  GoodsPageSynopsisView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "GoodsPageSynopsisView.h"
#import "UIView+DFCLayerCorner.h"
@interface GoodsPageSynopsisView ()
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UILabel *timer;
@property (weak, nonatomic) IBOutlet UILabel *synopsis;
@property (nonatomic,copy)  NSString *name;
@end

@implementation GoodsPageSynopsisView
+(GoodsPageSynopsisView*)initWithGoodsPageSynopsisViewFrame:(CGRect)frame titel:(NSString*)titel timer:(NSString*)timer synopsis:(NSString*)synopsis{
    GoodsPageSynopsisView *pageSynopsis = [[[NSBundle mainBundle] loadNibNamed:@"GoodsPageSynopsisView" owner:self options:nil] firstObject];
    pageSynopsis.frame = frame;
    pageSynopsis.name = titel;
    [pageSynopsis DFC_setPageSynopsisView];
//    pageSynopsis.timer.text = timer;
//    pageSynopsis.synopsis.text = synopsis;
    return pageSynopsis;
}



-(void)setTitel:(UILabel *)titel{
    NSString *str1 = @"太阳系八大行星";
    //NSString *str1 = self.name;
    long len1 = [str1 length];
    NSString *nameStr = @"  作者:童小毛";
    NSString *str = [NSString stringWithFormat:@"%@%@",str1,nameStr];
    long len2 = [nameStr length];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc]initWithString:str];
    [str2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:NSMakeRange(len1,len2)];
    titel.attributedText = str2;
}
@end

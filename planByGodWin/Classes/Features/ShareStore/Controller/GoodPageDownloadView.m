//
//  GoodPageDownloadView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "GoodPageDownloadView.h"
#import "UIView+DFCLayerCorner.h"

@implementation GoodPageDownloadView
+(GoodPageDownloadView*)initWithFrame:(CGRect)frame{
   GoodPageDownloadView *downloadView = [[[NSBundle mainBundle] loadNibNamed:@"GoodPageDownloadView" owner:self options:nil] firstObject];
    downloadView.frame = frame;
    [downloadView DFC_setLayerCorner];
    return downloadView;
}
- (IBAction)downloadAction:(UIButton *)sender {
    if ([self.protocol respondsToSelector:@selector(downloadAction:indexPath:)]) {
         [self.protocol  downloadAction:self indexPath:sender.tag];
    }
}

@end

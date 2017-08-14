//
//  DFCDowloadView.m
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDowloadView.h"

@interface DFCDowloadView ()
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end

@implementation DFCDowloadView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [_pageLabel DFC_setSelectedLayerCorner];
    [_downloadButton DFC_setSelectedLayerCorner];
}

+ (instancetype)dowloadView{
    return [[[NSBundle mainBundle]loadNibNamed:@"DFCDowloadView" owner:nil options:nil] firstObject];
}

- (void)setCurrentPage:(NSString *)currentPage{
    _pageLabel.text = currentPage;
}

- (IBAction)download:(UIButton *)sender { 
    if (self.downloadBlock) {
        self.downloadBlock();
    }
}
 
@end

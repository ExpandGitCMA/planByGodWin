//
//  DFCHeadButtonView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCHeadButtonView.h"
@interface DFCHeadButtonView ()
@property (weak, nonatomic) IBOutlet UILabel *goodLine;
@property (weak, nonatomic) IBOutlet UILabel *cloudLine;
@property (weak, nonatomic) IBOutlet UIButton *goodFn;
@property (weak, nonatomic) IBOutlet UIButton *cloudFn;
@property (weak, nonatomic) IBOutlet UILabel *line;
@property (nonatomic,assign)NSInteger signNum;//记录tag值
@end

@implementation DFCHeadButtonView
+(DFCHeadButtonView*)initWithDFCHeadButtonView{
   DFCHeadButtonView *headButton = [[[NSBundle mainBundle] loadNibNamed:@"DFCHeadButtonView" owner:self options:nil] firstObject];
    [headButton didSelectFn:headButton.goodFn];
    return headButton;
}

+(DFCHeadButtonView*)initWithAddSubviewGoodsUpload{
    DFCHeadButtonView *headButton = [[[NSBundle mainBundle] loadNibNamed:@"DFCHeadButtonView" owner:self options:nil] firstObject];
    headButton.line.hidden = NO;
    [headButton didSelectFn:headButton.goodFn];
    UILabel*line = [[UILabel alloc]initWithFrame:CGRectMake(0, headButton.frame.size.height-0.5, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headButton addSubview:line];
    return headButton;
}

- (IBAction)didSelectFn:(UIButton *)sender {
    if (self.signNum!=0) {
        UIButton *tempB = (UIButton *)[self viewWithTag:self.signNum];
        tempB.selected = NO;
    }
    sender.selected = YES;
    self.signNum = sender.tag;//记录点击btn的tag值
    if (sender.tag==1) {
        _cloudLine.hidden = YES;
        _goodLine.hidden = NO;
    }else{
        _cloudLine.hidden = NO;
        _goodLine.hidden = YES;
    }
    if ([self.protocol respondsToSelector:@selector(didSelectFn:indexPath:)]) {
        [self.protocol didSelectFn:self indexPath:sender.tag-1];
    }
}

@end

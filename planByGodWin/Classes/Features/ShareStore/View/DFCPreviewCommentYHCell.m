//
//  DFCPreviewCommentYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPreviewCommentYHCell.h"
#import "DFCStarRateView.h"

@interface DFCPreviewCommentYHCell ()
@property (weak, nonatomic) IBOutlet UIView *starRateView;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *fiveProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *fourProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *threeProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *twoProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *oneProgressView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentButtonConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineConstraint;

@property (nonatomic,strong) DFCStarRateView *rateView;
@end

@implementation DFCPreviewCommentYHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    DFCStarRateView *starRateView = [[DFCStarRateView alloc]initWithFrame:self.starRateView.bounds numberOfStars:5 rateStyle:DFCRateIncompleteStar isAnination:YES delegate:nil];
    self.rateView = starRateView;
    starRateView.userInteractionEnabled = NO;
    starRateView.currentScore = 0;
    [self.starRateView addSubview:starRateView];
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    _rateView.currentScore = _goodsModel.averageStore;
    _commentsCountLabel.text =_goodsModel.commentCount? [NSString stringWithFormat:@"(%ld)",_goodsModel.commentCount] : @"暂无评论";
    
    _fiveProgressView.progress = _goodsModel.fiveStarPercent;
    _fourProgressView.progress = _goodsModel.fourStarPercent;
    _threeProgressView.progress = _goodsModel.threeStarPercent;
    _twoProgressView.progress = _goodsModel.twoStarPercent;
    _oneProgressView.progress = _goodsModel.oneStarPercent;
}

- (void)previewCoursewareFromMystore{
    self.commentButtonConstraint.constant = 0;
    self.topLineConstraint.constant = 0;
    self.bottomLineConstraint.constant = 0;
    
    self.commentButton.hidden = YES;
    [self layoutIfNeeded];
}

/**
 写评论
 */
- (IBAction)comment {
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCurrentCourse)]) {
        [self.delegate commentCurrentCourse];
    }
}
@end

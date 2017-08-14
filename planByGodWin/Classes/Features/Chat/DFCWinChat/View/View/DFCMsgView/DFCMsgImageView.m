//
//  DFCMsgImageView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMsgImageView.h"
#import "UIImage+DFCImageCache.h"
@interface DFCMsgImageView ()
@property(nonatomic,strong)UIView*bgView;
@property (nonatomic, strong) UIImageView *msgImage;
@property (nonatomic, strong) UIImageView *bgImg;
@property (nonatomic, strong)NSString *imgUrl;
@end

@implementation DFCMsgImageView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //图片
        _msgImage = [[UIImageView alloc]initWithFrame:self.bounds];
        _msgImage.contentMode = UIViewContentModeScaleAspectFill;
        _msgImage.layer.cornerRadius = 10;
        _msgImage.clipsToBounds = YES;
        _msgImage.userInteractionEnabled = YES;

        UITapGestureRecognizer *top = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
        [_msgImage addGestureRecognizer:top];
        [self addSubview:_msgImage];
    }
    return self;
}

-(void)gestureAction:(UITapGestureRecognizer *)top{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _bgView.backgroundColor = [UIColor lightGrayColor];
    _bgView.alpha = 0.99;
    [[UIApplication sharedApplication].keyWindow addSubview:_bgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeLargePic:)];

    _bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/3, SCREEN_HEIGHT/3)];
    _bgImg.contentMode = UIViewContentModeScaleAspectFill;
    _bgImg.center=_bgView.center;
    _bgImg.backgroundColor = [UIColor orangeColor];
    [_bgImg sd_setImageWithURL:[NSURL URLWithString:_imgUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
    [_bgView addGestureRecognizer:tap];
    [_bgView addSubview:_bgImg];
}

-(void)removeLargePic:(UIGestureRecognizer *)myGes{
    //[myGes.view removeFromSuperview];
    [myGes.view removeFromSuperview];
    [_bgImg removeFromSuperview];
    [_bgView removeFromSuperview];
}

-(void)setMsgModel:(DFCMessageFrameModel *)msgModel{
     [super setMsgModel:msgModel];
//     self.msgButton.frame = self.bounds;
//     _msgImage.frame = self.msgButton.frame;
    
    if ([msgModel.model.type integerValue] == MessageFromMe) {
        NSString *url = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, msgModel.model.text];
        _imgUrl = url;
       [_msgImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
         [_bgImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
    } else {
        NSString *url = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, msgModel.model.text];
         _imgUrl = url;
        [_msgImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
    }

}
@end

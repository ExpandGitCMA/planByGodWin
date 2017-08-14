//
//  DFCYHTitleView.m
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCYHTitleView.h"
#define kMargin 3   // 间距
#define kDefaultFont [UIFont systemFontOfSize:18]   // 默认字体大小
@interface DFCYHTitleView ()

@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation DFCYHTitleView

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = _title;
    
    [self setNeedsLayout];
}

- (void)setImgName:(NSString *)imgName{
    _imgName = imgName;
    self.imgView.image = [UIImage imageNamed:_imgName];
    
     [self setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame imgName:(NSString *)imgName title:(NSString *)title{
    if (self = [super initWithFrame:frame]) {
        _imgName = imgName;
        _title = title;
        
        UIImage *contentImg = [UIImage imageNamed:_imgName];
        if (contentImg) {
            UIImageView *imgView = [[UIImageView alloc]init];
            imgView.image = contentImg;
            [self addSubview:imgView];
            self.imgView = imgView;
            
            UILabel *titleLabel = [[UILabel alloc]init];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = kUIColorFromRGB(ButtonGreenColor);
            titleLabel.text = _title;
            titleLabel.font = kDefaultFont;
            [self addSubview:titleLabel];
            self.titleLabel = titleLabel;
        }
    }
    return self;
}

+ (instancetype)titleViewWithFrame:(CGRect)frame ImgName:(NSString *)imgName title:(NSString *)title{
    return   [[DFCYHTitleView alloc]initWithFrame:frame imgName:imgName title:title];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIImage *contentImg = [UIImage imageNamed:_imgName];
    if (contentImg) {
        // 计算文字所占宽度(标题一般较短，暂不考虑较长的情况)
        CGSize size = [_title sizeWithAttributes:@{NSFontAttributeName:kDefaultFont}];
        // 图片和文字总长度
        CGFloat totalWidth = contentImg.size.width + size.width + kMargin * 3;
        // 图片位置
        if (self.bounds.size.width < totalWidth) {
            DEBUG_NSLog(@"给出的宽度不足");
        }else {
            self.imgView.frame = CGRectMake((self.bounds.size.width - totalWidth)/2 + kMargin , (self.bounds.size.height - contentImg.size.height)/2, contentImg.size.width, contentImg.size.height);
        }
        // label位置
        self.titleLabel.frame =CGRectMake(CGRectGetMaxX(_imgView.frame) + kMargin,(self.bounds.size.height - contentImg.size.height)/2, size.width, contentImg.size.height);
    }else {
        DEBUG_NSLog(@"图片不存在");
    }
}

@end

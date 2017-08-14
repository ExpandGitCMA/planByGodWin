//
//  DFCHomeFunctionView.m
//  planByGodWin
//
//  Created by zeros on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCHomeFunctionView.h"

@interface DFCHomeFunctionView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation DFCHomeFunctionView

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title
{
    if (self = [super init]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:imageView];
        self.imageView = imageView;
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.titleLabel = label;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterFunction)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)enterFunction
{
    if (_tapFun) {
        _tapFun();
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_imageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(_imageView.width).multipliedBy(212.0 / 326);
        make.top.equalTo(self);
        make.centerX.equalTo(self);
    }];
    [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(44);
    }];
}

@end

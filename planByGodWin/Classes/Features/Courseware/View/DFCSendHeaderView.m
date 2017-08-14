//
//  DFCSendHeaderView.m
//  planByGodWin
//
//  Created by zeros on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendHeaderView.h"
#import "DFCSendObjectModel.h"

@interface DFCSendHeaderView ()

/** 箭头*/
@property (strong, nonatomic) UIButton *arrowButton;
/** 人数*/
@property (strong, nonatomic) UILabel *personNumberLabel;

@property (nonatomic, copy) void(^selectFn)();

@end

@implementation DFCSendHeaderView

+ (instancetype)headerView:(UITableView *)tableView selectFn:(void (^)())selectFn
{
    static NSString *identifier = @"header";
    DFCSendHeaderView *headerView = (DFCSendHeaderView *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!headerView) {
        headerView = [[DFCSendHeaderView alloc] initWithReuseIdentifier:identifier];
        headerView.selectFn = selectFn;
    }
    return headerView;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self addSubview:self.arrowButton];
        [self addSubview:self.personNumberLabel];
        
        /** 添加一条线*/
        UIView *linesView = [[UIView alloc]initWithFrame:CGRectMake(0, 44 - 0.3, SCREEN_WIDTH, 0.3)];
        linesView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:linesView];
    }
    return self;
}

#pragma mark - 懒加载
- (UIButton *)arrowButton{
    if(!_arrowButton){
        _arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_arrowButton setBackgroundImage:[UIImage imageNamed:@"header_bg"] forState:UIControlStateNormal];
        [_arrowButton setBackgroundImage:[UIImage imageNamed:@"header_bg_highlighted"] forState:UIControlStateHighlighted];
        [_arrowButton setImage:[UIImage imageNamed:@"arrows_ mark"] forState:UIControlStateNormal];
        [_arrowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        /** 设置Button按钮内容的内边距*/
        [_arrowButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        /** 设置Button内容的位置居左*/
        [_arrowButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_arrowButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        /** 设置button图片的位置*/
        [_arrowButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_arrowButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        _arrowButton.imageView.clipsToBounds = NO;
//        _arrowButton.titleLabel.font = MAIN_FONT(15.f);
    }
    return _arrowButton;
}
- (UILabel *)personNumberLabel{
    if(!_personNumberLabel){
        // 创建label显示在线人数
        _personNumberLabel = [[UILabel alloc] init];
//        _personNumberLabel.text = @"12/52";
//        _personNumberLabel.font = MAIN_FONT(13.f);
        _personNumberLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _personNumberLabel;
}

#pragma mark - buttonAction
- (void)buttonAction
{
    self.group.isSelected = !self.group.isSelected;
    self.selectFn();
}
- (void)didMoveToSuperview
{
    /** 根据isSelected属性判断是否旋转？如果为YES，则旋转90°，否则不旋转*/
    self.arrowButton.imageView.transform = self.group.isSelected ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformMakeRotation(0);
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    /** 注意这里要设置为bounds 不然会出错*/
    self.arrowButton.frame = self.bounds;
    self.personNumberLabel.frame = CGRectMake(self.frame.size.width - 70, 0, 60, self.frame.size.height);
}

#pragma mark - group
-(void)setGroup:(DFCSendGroupModel *)group
{
    _group = group;
    self.personNumberLabel.text = [NSString stringWithFormat:@"%ld", group.objectList.count];
    [self.arrowButton setTitle:group.name forState:UIControlStateNormal];
}



@end

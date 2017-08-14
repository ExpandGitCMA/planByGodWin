//
//  DFCFileColorView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCFileColorView.h"
#import "DFCFileColorCell.h"
#import "DFCButton.h"
@interface DFCFileColorView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *xtCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,strong)NSArray*colorSource;
@property (nonatomic, strong)DFCButton*back;
@property (nonatomic, strong)UILabel*titel;
@end

@implementation DFCFileColorView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self titel];
        [self back];
        [self xtCollectionView];
    }
    return self;
}
-(DFCButton*)back{
    if (!_back) {
        _back = [[DFCButton alloc] initWithFrame:CGRectMake(0, 10,65, 44)];
        [_back setTitle:@"返回" forState:UIControlStateNormal];
        _back.titleLabel.font = [UIFont systemFontOfSize:16];
        [_back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_back addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_back];
    }
    return _back;
}
- (void)back:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(fileBack:)]) {
        [self.delegate fileBack:sender];
    }
}

-(UILabel*)titel{
    if (!_titel) {
        _titel = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-65)/2, 10, 65, 44)];
        _titel.text = @"模版";
        _titel.textColor = [UIColor whiteColor];
        _titel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titel];
    }
    return _titel;
}
- (UICollectionView *)xtCollectionView{
    if (!_xtCollectionView) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _xtCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 150, SCREEN_WIDTH,SCREEN_HEIGHT-150) collectionViewLayout:_flowLayout];
        _xtCollectionView.dataSource = self;
        _xtCollectionView.delegate = self;
        _xtCollectionView.backgroundColor = [UIColor clearColor];
        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [_xtCollectionView registerClass:[DFCFileColorCell class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_xtCollectionView];
    }
    return _xtCollectionView;
}

-(NSArray*)colorSource{
    if (_colorSource==nil) {
        _colorSource = @[@"#fffff1",@"#000000",@"#38625a",@"#004236",@"#306087",@"#0076e9",@"#e9af00",@"#a70000"];
    }
    return _colorSource;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.colorSource.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCFileColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"forIndexPath:indexPath];
    cell.backgroundColor = [self colorWithHex:[self.colorSource objectAtIndex:indexPath.row]];
    return cell;
}

- (UIColor *)colorWithHex:(NSString *)hexColor{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1];
}
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 10,20); // 顶部, left, 底部, right
}

//设置每个cell的大小 115
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/4-20, SCREEN_WIDTH/6-25);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//     DFCFileColorCell *cell = (DFCFileColorCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    DEBUG_NSLog(@"cell=%@",cell.backgroundColor);
    NSString*color = [_colorSource SafetyObjectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(fileColorCell:index:)]) {
        [self.delegate fileColorCell:color index:indexPath.row];
    }
}
@end

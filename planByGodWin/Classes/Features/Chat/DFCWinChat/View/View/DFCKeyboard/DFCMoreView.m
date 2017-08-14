//
//  DFCMoreView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMoreView.h"
#import "DFCMoreTool.h"
#import "DFCToolCell.h"
@interface DFCMoreView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,copy)NSMutableArray*arraySource;
@property(nonatomic,strong)UICollectionView *collectionView;

@end

@implementation DFCMoreView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _arraySource = [DFCMoreTool jsonWithTool];
        [self collectionView];
        UIView *underLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0.5, self.frame.size.width, 0.5)];
        underLine.backgroundColor = kUIColorFromRGB(LinToolColor);
        [self addSubview:underLine];
    }
    return self;
}
-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(100, 100);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = kUIColorFromRGB(DefaultColor);
        [_collectionView registerNib:[UINib nibWithNibName:@"DFCToolCell"  bundle:nil] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 40,15); // 顶部, left, 底部, right
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark-item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
 
    return _arraySource.count;

}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCToolCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    DFCMoreTool *model  = [_arraySource SafetyObjectAtIndex:indexPath.row];
    cell.title.text = model.titel;
    cell.tool.image = [UIImage imageNamed:model.tool];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(tool:toolType:)]&&self.delegate) {
        [self.delegate tool:self toolType:indexPath.row];
    }
}

@end
